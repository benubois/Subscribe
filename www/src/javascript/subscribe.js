var Subscribe;

Subscribe = {
  version: '1.0.0',
  log: function() {
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
    if ('browser' === Subscribe.env()) {
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
    apiClient = new Subscribe.ReaderApi;
    login = apiClient.login();
    return login.done(function() {
      Subscribe.apiClient = apiClient;
      return $(document).trigger('subscribeLogin');
    });
  },
  loginDone: function() {
    return $(document).on('subscribeLogin', function() {
      return Subscribe.apiClient.list();
    });
  },
  subscriptionTouch: function() {
    return $('#jqt').on('tap', '.subscription', function(e) {
      return Subscribe.action.detail($(this));
    });
  }
};

Subscribe.action = {
  subscribe: function() {
    var url;
    url = $('#url').val();
    return Subscribe.apiClient.request(url);
  },
  detail: function(feed) {
    var feedId, request, title;
    feedId = feed.attr('id');
    title = {
      title: feed.text()
    };
    $("#title").html(ich.title_template(title));
    request = Subscribe.apiClient.details(feedId);
    request.done(function(data) {
      return $("#details").html(ich.details_template(data));
    });
    return request.fail(function(data) {
      return console.log('detail fail');
    });
  }
};

Subscribe.load = function() {
  if ('browser' === Subscribe.env()) {
    $(document).ready(function() {
      return Subscribe.onDeviceReady();
    });
  } else {

  }
  return document.addEventListener("deviceready", Subscribe.onDeviceReady, false);
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

Subscribe.ReaderApi = (function() {

  function ReaderApi() {
    this.host = Subscribe.host();
    this.auth = null;
    this.token = null;
  }

  ReaderApi.prototype.subscribe = function(domain) {
    var subRequest;
    var _this = this;
    subRequest = this._subscribe(domain);
    return subRequest.fail(function(data) {
      var login;
      if (400 === data.status) {
        login = _this.login();
        login.done(function() {
          return subRequest = _this._subscribe(domain);
        });
        return login.fail(function() {
          return alert('Couldn’t log in after 2 tries');
        });
      }
    });
  };

  ReaderApi.prototype.details = function(feedId) {
    var dfd, subRequest;
    var _this = this;
    dfd = $.Deferred();
    subRequest = this._details(feedId);
    subRequest.success(function(data) {
      return dfd.resolve(data);
    });
    subRequest.fail(function(data) {
      var login;
      if (400 === data.status) {
        login = _this.login();
        login.done(function() {
          subRequest = _this._details(feedId);
          return subRequest.success(function(data) {
            return dfd.resolve(data);
          });
        });
        return login.fail(function() {
          dfd.reject;
          return alert('Couldn’t log in after 2 tries');
        });
      }
    });
    return dfd.promise();
  };

  ReaderApi.prototype._details = function(feedId) {
    return $.ajax({
      url: "" + this.host + "/reader/api/0/stream/details",
      data: {
        s: feedId,
        tz: '-480',
        fetchTrends: 'false',
        output: 'json',
        client: "Subscribe/" + Subscribe.version,
        ck: Math.round(new Date().getTime())
      },
      dataType: 'json',
      headers: {
        "Authorization": "GoogleLogin auth=" + this.auth
      },
      success: function(data) {}
    });
  };

  ReaderApi.prototype.list = function() {
    return $.ajax({
      url: "" + this.host + "/reader/api/0/subscription/list",
      data: {
        output: "json",
        ck: Math.round(new Date().getTime() / 1000),
        client: "Subscribe/" + Subscribe.version
      },
      dataType: 'json',
      headers: {
        "Authorization": "GoogleLogin auth=" + this.auth
      },
      success: function(data) {
        var content;
        if (0 === data.subscriptions.length) {
          data.condition_no_subscriptions = true;
          data.condition_has_subscriptions = false;
        } else {
          data.condition_no_subscriptions = false;
          data.condition_has_subscriptions = true;
        }
        content = ich.subscriptions_list(data);
        return $("#subscriptions").html(content);
      },
      error: function(data) {
        return console.log(data);
      }
    });
  };

  ReaderApi.prototype._subscribe = function(domain) {
    var queryString;
    queryString = $.param({
      client: "Subscribe/" + Subscribe.version,
      quickadd: domain,
      ac: 'subscribe',
      T: this.token
    });
    return $.ajax({
      type: "POST",
      url: "" + this.host + "/reader/api/0/subscription/quickadd?" + queryString,
      dataType: 'json',
      headers: {
        "Content-Length": '0',
        "Authorization": "GoogleLogin auth=" + this.auth,
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
      },
      success: function(data) {
        console.log(data);
        if (data.streamId != null) {
          return alert('subscription success');
        } else {
          return console.log('no subscription');
        }
      }
    });
  };

  ReaderApi.prototype.login = function() {
    var credentials, dfd;
    var _this = this;
    dfd = $.Deferred();
    credentials = Subscribe.getLogin();
    credentials.done(function(login) {
      var authRequest;
      authRequest = _this.getAuth(login.username, login.password);
      authRequest.success(function(data) {
        var tokenRequest;
        return tokenRequest = _this.getToken(_this.auth, dfd);
      });
      return authRequest.error(function(data) {
        return dfd.reject();
      });
    });
    return dfd.promise();
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
        Subscribe.log(data);
        return alert('Invalid username or password');
      }
    });
  };

  ReaderApi.prototype.getToken = function(auth, dfd) {
    var _this = this;
    return $.ajax({
      url: "" + this.host + "/reader/api/0/token",
      headers: {
        "Content-type": "application/x-www-form-urlencoded",
        "Authorization": "GoogleLogin auth=" + auth
      },
      success: function(data) {
        _this.token = data;
        return dfd.resolve();
      },
      error: function(data) {
        return alert('Authentication error');
      }
    });
  };

  return ReaderApi;

})();
