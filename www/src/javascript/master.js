var ReaderApi, client, config, getAuth, getToken, init, logPush, onDeviceReady;

logPush = function() {
  window.logHistory = window.logHistory || [];
  window.logHistory.push(arguments);
  if (window.console) return console.log(Array.prototype.slice.call(arguments));
};

ReaderApi = (function() {

  function ReaderApi(options) {
    this.host = 'http://subscribe.benubois.com.dev/index.php';
    this.auth = null;
    this.token = null;
    this.login(options);
  }

  ReaderApi.prototype.readerSubscribe = function(domain) {
    var _this = this;
    return $.ajax({
      url: "" + this.host + "/accounts/ClientLogin",
      data: {
        "quickadd": this.domain,
        "ac": 'subscribe',
        "T": this.token
      },
      headers: {
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        "Content-Length": '0',
        "Authorization": "GoogleLogin auth=" + this.auth
      },
      success: function(data) {
        return console.log(successfully(subscribed));
      },
      error: function(data) {
        return console.log(subscription(error));
      }
    });
  };

  ReaderApi.prototype.login = function(options) {
    var authRequest;
    var _this = this;
    authRequest = this.getAuth(options.username, options.password);
    authRequest.success(function(data) {
      var tokenRequest;
      return tokenRequest = _this.getToken(_this.auth);
    });
    return authRequest.error(function(data) {
      return alert('Invalid username or password');
    });
  };

  ReaderApi.prototype.getAuth = function(username, password) {
    var _this = this;
    return $.ajax({
      url: "" + this.host + "/accounts/ClientLogin",
      data: {
        "service": "reader",
        "Email": username,
        "Passwd": password
      },
      success: function(data) {
        return _this.auth = data.match(/Auth=(.*)/)[1];
      },
      error: function(data) {
        return alert('Authentication error');
      }
    });
  };

  ReaderApi.prototype.getToken = function(auth) {
    var _this = this;
    return $.ajax({
      url: "" + this.host + "/reader/api/0/token",
      headers: {
        "Content-type": "application/x-www-form-urlencoded",
        "Authorization": "GoogleLogin auth=" + auth
      },
      success: function(data) {
        return _this.token = data;
      },
      error: function(data) {
        return alert('Authentication error');
      }
    });
  };

  return ReaderApi;

})();

client = new ReaderApi({
  username: 'bbsaid',
  password: 'Vhv94X(ZF;BWyW'
});

config = {
  env: function() {
    if (window.location.hostname === 'subscribe.benubois.com.dev') {
      return 'browser';
    } else {
      return 'device';
    }
  },
  host: function() {
    var host;
    if ('browser' === config.env()) {
      return host = 'http://subscribe.benubois.com.dev/index.php';
    } else {
      return host = 'https://www.google.com';
    }
  }
};

getAuth = function(user, pass, cb) {
  return $.ajax({
    url: "" + (config.host()) + "/accounts/ClientLogin",
    data: {
      "service": "reader",
      "Email": user,
      "Passwd": pass
    },
    success: function(data) {
      return cb(data.match(/Auth=(.*)/)[1]);
    },
    error: function(data) {
      return alert('failed');
    }
  });
};

getToken = function(auth, cb) {
  return $.ajax({
    url: "" + (config.host()) + "/reader/api/0/token",
    headers: {
      "Content-type": "application/x-www-form-urlencoded",
      "Authorization": "GoogleLogin auth=" + auth
    },
    success: function(data) {
      return cb(data);
    }
  });
};

onDeviceReady = function() {
  var _this = this;
  return $('#button-login').on('tap', function() {
    var pass, user;
    logPush('something');
    user = $('input[name="username"]').val();
    pass = $('input[name="password"]').val();
    return getAuth(user, pass, function(auth) {
      return getToken(auth, function(token) {
        return alert(token);
      });
    });
  });
};

init = function() {
  if ('browser' === config.env()) {
    $(document).ready(function() {
      return onDeviceReady();
    });
  } else {

  }
  return document.addEventListener("deviceready", onDeviceReady, false);
};
