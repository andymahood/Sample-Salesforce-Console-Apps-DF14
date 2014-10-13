$(function() {

    var liveAgentCheckInterval;
    var buttonName = 'Service SOS';
    var flashInterval;
    var lastShade = '#c0e2ea';
    var newReqs = 0;
    var oldReqs = 0;
    var requests = {};

    // Element References
    var sosStatusButton = $('.sos-button.status');

    // Feature flags to make it easier to disable features
    var featureFlags = {
    	skillsRouting: false,		// you need to be in the SOS skills to access the queue
    	agentState: false           // poll agent state and disable queue when there are active liveagent sessions
    };

    // Keys
    var sosKey;

    // Use this to retrieve the nonce off the original request.
    localStorage.setItem('queueParams', window.location.search);

    // Make the session timestamp update every second and also display the seconds updating
    jQuery.timeago.settings.refreshMillis = 1000;
    jQuery.timeago.settings.strings.seconds = '%d seconds';

    // Bind to goinstant connected event to load queue
    $(document).bind('GOINSTANT_CONNECTED', loadQueue);

    // Init GoInstant
    var goVF = new goinstantVF({
        connectUrl: window.sosVars.connectUrl,
        debugLevel: 4 // 0 debug | 1 test | 2 info | 3 warn | 4 error
    });

    // Connect to agent lobby
    goVF.connect('sos_agent_room');

    /* Check liveagent status and disable SOS queue when agent is in active live agent sessions */
    if (featureFlags.agentState) {
		liveAgentCheckInterval = setInterval(function() {
	    	checkLiveAgentStatus();
	    }, 2000);
    }

    /**
     * getQueuePermission
     *
     * Check whether the user or user profile has access to the SOS skill queue.
     *
     * returns bool
     */
    function getQueuePermission() {
        var userQuery = "SELECT Id, IsDeleted, SkillId, Skill.Id, UserId FROM SkillUser WHERE Skill.MasterLabel = 'SOS' and UserId = '"+ sosVars.userId +"'";
        var userQuery = sforce.connection.query(userQuery);
        var userSOSSkill = userQuery.getArray('records').length;

        var profileQuery = "SELECT Id, IsDeleted, ProfileId,SkillId, SystemModstamp, Skill.MasterLabel "
                         + "FROM SkillProfile "
                         + "WHERE ProfileId = '" + sosVars.userProfile + "' and Skill.MasterLabel = 'SOS'";
        var profileQuery = sforce.connection.query(profileQuery);
        var profileSOSSkill = profileQuery.getArray('records').length;

        var sosAccess = userSOSSkill || profileSOSSkill;

        return sosAccess;
    }

    function loadQueue() {

        // Check if agent is already in a session
        goVF.rooms.giLobby.self().key('activeSession').get(function(err, val, context) {
            if (err) {
                console.log('Couldnt verify agent session status');
            }

            if (val) {
                // There's a val. Join the room and count the users
                goVF.joinRoom(val, function(err, room) {
                    room.users.get(function(err, users, context) {
                        if (_.size(users) >= 2) {
                            window.location = '/apex/GoInstant_Sidebar_SOS';
                        } else {
                            goVF.rooms.giLobby.self().key('activeSession').remove();
                        }
                    });
                });
            }
        });

        goinstantVF.info('LOAD QUEUE');
        sosKey = goVF.rooms.giLobby.key('requests');

        $('.clear-queue').click(function() {
            showModal('Are you sure you want to clear the entire queue?', function() {
                sosKey.remove({
                    local: true
                }, function() {
                    goinstantVF.info('All pending requests have been removed');
                });
            });
        });

        if (featureFlags.skillsRouting) {
            $('.header .statusButton').show();
            if (getQueuePermission()) {
                if (sessionStorage.getItem('sosOnline') != 'true') {
                    sessionStorage.setItem('sosOnline') = 'false';
                    setSosButton('off');
                }

                if (sessionStorage.getItem('sosOnline') == "true") {
                    addSOSListeners();
                    setSosButton('on');
                }
            } else {
                $('#sos_queue').css({
                    padding: 20,
                    color: '#f00'
                }).text('You are currently not assigned to the SOS Queue');

                setSosButton('disabled');

                $('.clear-queue').css({
                    color: '#ccc'
                });

                // If no access, stop checking for liveagent session
                clearInterval(liveAgentCheckInterval);
            }

            sosStatusButton.click(function(e) {
                e.preventDefault();

                if (sosStatusButton.prop('enabled') == false) {
                    return;
                }

                if (sosStatusButton.prop('enabled') == true && sessionStorage.getItem('sosOnline') == "false") {
                    addSOSListeners();
                } else {
                    removeSOSListeners();
                }
            });
        } else {
            addSOSListeners();
        }
    }

    function setSosButton(status) {
        if (status == "on") {
            sessionStorage.setItem('sosOnline', 'true');
            sosStatusButton.css({
                color: '#00aa00'
            }).prop('enabled', true).text('Online');
        }

        if (status == "off") {
            sessionStorage.setItem('sosOnline', 'false');
            sosStatusButton.css({
                color: '#ff0000'
            }).prop('enabled', true).text('Offline');
        }

        if (status == 'disabled') {
            sessionStorage.setItem('sosOnline', 'false');
            sosStatusButton.css({
                color: '#ccc'
            }).prop('enabled', false).text('Offline');
        }
    }

    function addSOSListeners() {

        setSosButton('on');

        //initial loading of the queue
        refreshQueue(true);

        sosKey.on('set', {
            bubble: true,
            listener: newEntry,
            local: true
        });

        sosKey.on('remove', {
            bubble: true,
            listener: refreshQueue, //we have to refresh the entire queue since we do not know what was removed
            local: true
        });
    }

    function removeSOSListeners() {
        setSosButton('off');
        sosKey.off('remove');
        sosKey.off('set');
        $('#sos_queue').empty();
        setButtonText();
        stopFlashAlert();
    }

    function refreshQueue(initialLoad) {
        newReqs = 0;
        requests = {};
        
        sosKey.get(function(err, queueData) {
            if (err) {
                return goinstantVF.error('Refresh error:' , err);
            }

            $('#sos_queue').text('');

            _.map(_.sortBy(queueData, 'timestamp'), function(val) {
                newReqs++;

                goinstantVF.info({
                    msg: 'val key',
                    val: val
                });

                requests[val.pin] = val;
                appendRequestMarkupToQueue(val, newReqs);
            });

            if (initialLoad) {
                flashAlert(newReqs);
            } else if (newReqs > 0) {
                setButtonText(newReqs);
            } else {
                stopFlashAlert();
            }
        });
    }

    function setButtonText(reqs) {
        var newText = reqs ? buttonName + ' - ' + reqs : buttonName;
        sforce.console.setCustomConsoleComponentButtonText(newText);
    }

    function setWindowSize(width, height) {
        /*
         * currently no resize alternative

        if (canvasVersion == '30.0') {
            sosWidgetController.widgetWindow.setSize(width,height);
        } else {
            sosWidgetController.widgetWindow.updateBox({ width: width, height: height });
        }
        */
    }

    function setButtonBgColor(color) {
        if (!color) {
            return;
        }

        sforce.console.setCustomConsoleComponentButtonStyle('background-color: ' + color + ';');
    }

    function flashAlert(reqs) {
        startFlashing = function() {
            flashInterval = setInterval(function() {
                lastShade = lastShade == '#E4F3F7' ? '#149BC8' : '#E4F3F7';
                setButtonBgColor(lastShade);
            }, 700);
        }

        if(!flashInterval && reqs) {
            if (reqs > oldReqs) {
                var audioEl = document.getElementsByTagName("audio")[0];
                audioEl.play();
            }

            oldReqs = reqs;

            sforce.console.isCustomConsoleComponentWindowHidden(function(a) {
                if (a.hidden) {
                    startFlashing();
                }
            });
        }

        if (reqs > 0) {
            setButtonText(reqs);
        } else {
            stopFlashAlert();
        }
    }

    function stopFlashAlert() {
        setButtonBgColor('transparent');
        setButtonText(false);
        clearInterval(flashInterval);
        flashInterval = null;
    }

    function newEntry(val) {
        goinstantVF.info({
            msg: 'new entry',
            entry: val
        });
        newReqs++;
        flashAlert(newReqs);
        appendRequestMarkupToQueue(val, newReqs);
        requests[val.pin] = val;
    }

    function removeItem(requestId) {
        showModal('Are you sure you want to remove this request?', function() {
            sosKey.key(requestId).remove({
                local: true
            }, function() {
                goinstantVF.info('Request id: ' + requestId + ' has been removed');
            });
        });
    }

    function appendRequestMarkupToQueue(obj, index) {
        obj.timestamp = fixTimestamp(obj.timestamp);

        var itemDate = new Date(obj.timestamp);

        // Fetch mustache template
        var template = $('#queueRequest').text();

        // jQuery object of request markup
        var htmlString = $(Sfdc.Template.render(template, {
            pin: obj.pin,
            email: obj.email,
            timeago: itemDate.toISOString(),
            appVersion: obj.transcript.appVersion,
            device: obj.transcript.type,
            deviceVersion: obj.transcript.os,
            resolution: obj.transcript.resolution.width + 'x' + obj.transcript.resolution.height
        }));

        // Bind event listeners on buttons
        htmlString.find('.timeago').timeago();
        htmlString.find('.cancel').click(function() {
            removeItem(obj.pin);
        });
        htmlString.find('.launch').click(function() {
            takeRequestFromQueue(obj.pin);
        });

        // We display the extended information for hte first three sessions
        // remaining sessions will show extended info on hover.
        if (index > 3) {
            htmlString.mouseenter(function() {
                $(this).find('.queue_details').slideDown('fast');
            }).mouseleave(function() {
                $(this).find('.queue_details').stop().slideUp('fast');
            });
        } else {
            htmlString.find('.queue_details').css({ display: 'block' });
        }

        // Add markup to DOM
        $('#sos_queue').append(htmlString);
    }

    // Normalize timestamp to ms
    function fixTimestamp(timestamp) {
        if (typeof timestamp == 'string') {
            timestamp = 1000 * parseInt(timestamp, 10);
        }

        return timestamp;
    }

    function takeRequestFromQueue(pin) {
        newReqs--;
        setButtonText(newReqs);

        sessionStorage.setItem('sosRoom', pin);
        sessionStorage.setItem('sosRoomDetails', JSON.stringify(requests[pin]));

        $('#'+pin).addClass('opening');
        sosKey.key(pin).remove({lastValue: true}, function(err, lastVal) {
            if (err) {
                return console.log('Remove err: ', err);
            }

            if (!lastVal) {
                //someone else took it
                refreshQueue();
            }

            $('#'+pin).remove();

            // Find customer account ID
            var q = "SELECT Id, AccountId, Email, FirstName, LastName FROM Contact WHERE Email = '" + lastVal.email + "'";
            var qr = sforce.connection.query(q);
            var records = qr.getArray('records');

            var isUser;

            if (records.length === 0) {
                return alert('No contacts with email: ' + lastVal.email);
            } else {
                lastVal.transcript.contactId = records[0].Id;
            }

            // Create new Case SObject
            var newCase = new sforce.SObject('Case');

            newCase.Subject = 'Salesforce SOS';
            newCase.ContactId = qr.records.Id;

            var createdCases = sforce.connection.create([newCase]);
            var caseData = sforce.connection.retrieve('caseNumber', 'Case', [createdCases[0].id]);

            sforce.console.openPrimaryTab(null, '/' + createdCases[0].id, true, createdCases[0].CaseNumber, function(res) {
                lastVal.transcript.case = createdCases[0].id;
                lastVal.transcript.caseNumber = caseData[0].CaseNumber;
                lastVal.transcript.caseTabId = res.id;
                lastVal.transcript.requestTime = fixTimestamp(lastVal.timestamp);

                giTranscript(pin, lastVal, function() {
                    goinstantVF.info('Setting agent session info on lobby user');
                    goVF.rooms.giLobby.self().key('activeSession').set(pin, function(err, val) {
                    	window.location = '/apex/GoInstant_Sidebar_SOS';
                    });
                });
            });

        });
    }

    sforce.console.onCustomConsoleComponentButtonClicked(function() {
        setButtonBgColor('transparent');
        clearInterval(flashInterval);
        flashInterval = null;
    });

    /** Not until v30
    // To do when the SOS Widget is popped out
    if (sosWidgetController && sosWidgetController.isPoppedOut()) {
        $(function() {

            // Bind focus and click on window so we can make the custom component button stop
            // flashing when we interact with the popout

            $(window).bind('focus click', function() {
                setButtonBgColor('transparent');
                clearInterval(flashInterval);
                flashInterval = null;
            }).trigger('focus');

        });
    }
    */

    function showModal(msg, callback) {
        $modal = $('.overlayContents');
        $bg = $('.overlayBg');
        $msg = $modal.find('.msg');

        $msg.text(msg);
        $bg.fadeIn();
        $modal.fadeIn();

        function cancel() {
            $modal.find('.buttons').off('click', '.ok', ok);
            $modal.find('.buttons').off('click', '.cancel', cancel);

            $modal.fadeOut();
            $bg.fadeOut();
        }

        function ok() {
            $modal.find('.buttons').off('click', '.ok', ok);
            $modal.find('.buttons').off('click', '.cancel', cancel);

            callback.call();
            $modal.fadeOut();
            $bg.fadeOut();
        }

        $modal.find('.buttons').on('click', '.ok', ok);
        $modal.find('.buttons').on('click', '.cancel', cancel);
    }

    function giTranscript(pin, transcriptData, cb) {
        var transRoomName = pin + '-transcript';

        goVF.joinRoom(transRoomName, function(err, transRoom) {

            if (err) {
                throw new Error('Could not connect to transcript room');
            }

            goVF.joinRoom(pin, function(err, normalRoom) {
                if (err) {
                    throw new Error('Could not connect to normal room to set data');
                }

                var storeData = transcriptData.transcript;
                storeData.time = {
                    start: new Date().getTime()
                };

                // Sessions always have two users.
                storeData.session_size = 2;
                storeData.username = transcriptData.email;

                if (!window.location.origin) {
                    window.location.origin = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port: '');
                }
                var endSessionUrl = window.location.origin + '/apex/goinstant_demo_sos_ended?room='+pin;

                normalRoom.key('end_session_url').set(endSessionUrl, function(err) {
                    if (err) {
                        console.log('ERROR - unable to set sf_domain', err);
                    }

                    transRoom.key('transcript').set(storeData, function() {
                        normalRoom.leave().then(function() {
                            transRoom.leave().then(function() {
                                cb();
                            }).catch(function(err) {
                                console.log('Error leaving transcript room', err);
                            });
                        })
                        .catch(function(err) {
                            console.log('Error leaving normal room', err);
                        });
                    });
                });
            });

        });
    }

    function checkLiveAgentStatus() {
        sforce.console.chat.getEngagedChats(function(a) {
            // If there are active liveagent sessions and the sos queue hasn't been turned off yet
            if (a.success && a.chatKey.length && sessionStorage.getItem('sosTempOffline') != 'true') {
                var lastState = {
                    enabled: sosStatusButton.prop('enabled'),
                    state: sessionStorage.getItem('sosOnline')
                };
                sessionStorage.setItem('sosLastButtonState', JSON.stringify(lastState));

                removeSOSListeners();
                setSosButton('disabled');
                sessionStorage.setItem('sosTempOffline', 'true');
                return;
            }

            // If there are no active liveagent sessions, sos is not online, it was
            // temporarily turned off because of previous liveagent chats.
            // (coming back online from active liveagent sessions)
            if (a.success && a.chatKey.length == 0 && sessionStorage.getItem('sosOnline') == 'false' &&
                sessionStorage.getItem('sosTempOffline') == 'true') {

                sessionStorage.setItem('sosTempOffline', 'false');

                var lastState = JSON.parse(sessionStorage.getItem('sosLastButtonState'));
                sessionStorage.removeItem('sosLastButtonState');

                if (lastState.enabled) {
                    if (lastState.state == 'false') {
                        setSosButton('off');
                        return;
                    }

                    setSosButton('on');
                    addSOSListeners();
                } else {
                    setSosButton('disabled');
                }
            }
        });
    }

});
