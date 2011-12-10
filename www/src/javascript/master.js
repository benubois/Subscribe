var Subscribe, init;

Subscribe = {
  logPush: function() {
    window.logHistory = window.logHistory || [];
    window.logHistory.push(arguments);
    if (window.console) return console.log(Array.prototype.slice.call(arguments));
  },
  env: function() {
    if (window.location.hostname === 'subscribe.benubois.com.dev') {
      return 'browser';
    } else {
      return 'device';
    }
  },
  host: function() {
    var host;
    if ('browser' === Subscribe.config.env()) {
      return host = 'http://subscribe.benubois.com.dev/index.php';
    } else {
      return host = 'https://www.google.com';
    }
  },
  onDeviceReady: function() {
    return $.each(Subscribe.init, function(i, item) {
      return item();
    });
  }
};

Subscribe.init = {
  login: function() {
    var apiClient, login;
    console.log('login');
    apiClient = new Subscribe.ReaderApi;
    login = apiClient.login();
    return login.done(function() {
      Subscribe.apiClient = apiClient;
      return $(document).trigger('subscribeLogin');
    });
  },
  loginDone: function() {
    return $(document).on('subscribeLogin', function() {
      Subscribe.apiClient.list();
      return Subscribe.apiClient.subscribe();
    });
  }
};

Subscribe.getLogin = function() {
  var dfd;
  dfd = $.Deferred();
  dfd.resolve({
    username: 'subscribeapp.testing',
    password: 'hAMWCY2+Jfb7,q'
  });
  return dfd.promise();
};

init = function() {
  if ('browser' === Subscribe.env()) {
    $(document).ready(function() {
      return Subscribe.onDeviceReady();
    });
  } else {

  }
  return document.addEventListener("deviceready", Subscribe.onDeviceReady, false);
};
