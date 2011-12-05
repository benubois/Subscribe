var getAuth, getToken, init, onDeviceReady;

getAuth = function(user, pass, cb) {
  alert(user);
  alert(pass);
  return $.ajax({
    url: "https://www.google.com/accounts/ClientLogin",
    data: {
      "service": "reader",
      "Email": user,
      "Passwd": pass
    },
    success: function(data, textStatus) {
      return cb(data.match(/Auth=(.*)/)[1]);
    },
    error: function(data) {
      return alert('failed');
    }
  });
};
getToken = function(auth, cb) {
  return $.ajax({
    url: "http://www.google.com/reader/api/0/token",
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
  return document.addEventListener("deviceready", onDeviceReady, false);
};
