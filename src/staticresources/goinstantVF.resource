(function() {

  goinstantVF = function(config) {
    this.settings = {
      connectUrl: '',
      autoConnect: false,
      debugLevel: 4
    };
    this.rooms = {};
    this.isAgent = false;
    this.connection = null;

    this.init(config);
  }

  goinstantVF.logLevel = 4;

  goinstantVF.prototype.init = function(config) {
    this.settings = jQuery.extend({}, this.settings, config);
    goinstantVF.logLevel = this.settings.debugLevel;
  };

  goinstantVF.logLevels = {
    DEBUG: 0,
    TEST: 1,
    INFO: 2,
    WARN: 3,
    ERROR: 4
  };

  goinstantVF.log = function(msg, type) {
    type =  type || 'DEBUG';

    if ( goinstantVF.logLevel > goinstantVF.logLevels[type]) {
      return;
    }

    try {
      if (typeof console === 'object') {
        if (typeof msg === 'string') {
          console.log(type + ': ' + msg);
        } else {
          console.log('<log:' + type + '>');
          console.log(msg);
          console.log('</log:' + type + '>');
        }
      }
    } catch (e) {};
  };

  goinstantVF.test = function(msg) { goinstantVF.log(msg, 'TEST'); };
  goinstantVF.info = function(msg) { goinstantVF.log(msg, 'INFO'); };
  goinstantVF.warn = function(msg) { goinstantVF.log(msg, 'WARN'); };
  goinstantVF.error = function(msg) { goinstantVF.log(msg, 'ERROR'); };

  goinstantVF.prototype.connect = function(roomName, cb) {

    var self = this;

    cb = cb || function() {};
    var fullUrl = this.getConnectUrl();

    goinstant.connect(fullUrl, {rooms: [roomName, 'lobby']}, function(err, connection, roomObj, lobby) {

      if (err) {
        goinstantVF.error({
          msg: 'Error connecting to GoInstant',
          err: err,
          errMessage: err.message
        });
        return;
      }

      self.rooms.giLobby = lobby;
      self.rooms.giRoom = roomObj;
      self.connection = connection;

      lobby.self().key('isAgent').get(function(err, val) {
        if (err) {
          goinstantVF.warn({
            msg: 'Error checking if agent',
            err: err
          });
        }

        this.isAgent = val;

        $(document).trigger('GOINSTANT_CONNECTED');

        cb();
      });

    });
  };

  goinstantVF.prototype.joinRoom = function(roomName, cb) {
    var self = this;

    var thisRoom = this.connection.room(roomName);
    thisRoom.join(function(err, room, userData) {
      if (err) {
        return cb(err);
      }

      self.rooms[roomName] = room;

      cb(false, room);
    });
  };

  goinstantVF.prototype.getConnectUrl = function() {
    if (!this.settings.connectUrl) {
      throw new Error('GoInstant connection url required (custom setting)');
    }

    return this.settings.connectUrl;
  };

})();