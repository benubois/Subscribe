var config, getAuth, getToken, init, onDeviceReady;

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
    return $(document).ready(function() {
      return onDeviceReady();
    });
  } else {
    return document.addEventListener("deviceready", onDeviceReady, false);
  }
};
