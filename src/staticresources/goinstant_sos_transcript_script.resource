var goinstantUtils = {
    getTranscriptData: function(opts, cb) {
        goinstant.connect(opts.giConnectUrl, {room: opts.transcriptRoomName}, function(err, connection, transRoom) {
            if (err) {
                return console.log('Transcript end - unable to connect', err);
            }

            var transKey = transRoom.key('transcript');

            transKey.get(function(err, transData) {
                if (err) {
                    console.log('Transcript end - unable to get data', err);
                    return cb(err);
                }

                if (!transData) {
                    console.log('Transcript end - no data');
                    return cb('no data');
                }

                transKey.remove();

                transData.giAccount = opts.giAccount;
                cb(null, transData);
            });
        });
    },
    getDurationText: function(start, end) {
        var dur = end - start;
        var minutes = Math.floor(dur/60000);
        var seconds = Math.floor((dur - (minutes * 60000)) / 1000);

        var minText;
        var secText;

        if (minutes === 1) {
            minText = '1 min ';
        } else {
            minText = minutes + ' mins ';
        }

        if (seconds === 1) {
            secText = '01 sec' ;
        } else if (seconds < 10) {
            secText = '0'+seconds + ' secs';
        } else {
            secText = seconds + ' secs';
        }

        return minText + secText;
    },
    returnToQueue: function() {
        sforce.console.fireEvent('salesforce.sos', JSON.stringify({
            command: 'setLocationURI',
            src: '/apex/goinstant_sos_queue' + localStorage.queueParams
        }), function(res) {
        });
    }
};