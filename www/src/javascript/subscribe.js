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
      return Subscribe.action.list();
    });
  },
  buttons: function() {
    $('#jqt').on('tap', '.subscription', function(e) {
      return Subscribe.action.detail($(this));
    });
    return $('#jqt').on('tap', '.unsubscribe', function(e) {
      return Subscribe.action.unsubscribe($(this));
    });
  }
};

Subscribe.action = {
  list: function() {
    var request;
    request = Subscribe.apiClient.list();
    request.done(function(data) {
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
    });
    return request.fail(function(data) {
      return console.log(data);
    });
  },
  subscribe: function() {
    var request, url;
    url = $('#url').val();
    request = Subscribe.apiClient.subscribe(url);
    request.done(function(data) {
      return Subscribe.action.list();
    });
    return request.fail(function(data) {
      return alert('subscribe failed');
    });
  },
  unsubscribe: function(el) {
    var feedId, request;
    feedId = el.data('feed-id');
    request = Subscribe.apiClient.unsubscribe(feedId);
    request.done(function(data) {
      return Subscribe.action.removeSubscription(feedId);
    });
    return request.fail(function(data) {
      return alert('unsubscribe failed');
    });
  },
  removeSubscription: function(id) {
    return $('#subscriptions').find('li a').each(function() {
      if ($(this).data('feed-id') === id) return $(this).parents('li').remove();
    });
  },
  detail: function(el) {
    var feedId, request, title;
    feedId = el.data('feed-id');
    title = {
      title: el.text()
    };
    $("#title").html(ich.title_template(title));
    request = Subscribe.apiClient.details(feedId);
    request.done(function(data) {
      data.id = feedId;
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
    var dfd, subRequest;
    var _this = this;
    dfd = $.Deferred();
    subRequest = this._subscribe(domain);
    subRequest.success(function(data) {
      if (data.streamId != null) {
        return dfd.resolve(data);
      } else {
        return dfd.reject('invalid feed');
      }
    });
    subRequest.fail(function(data) {
      var login;
      if (400 === data.status) {
        login = _this.login();
        login.done(function() {
          subRequest = _this._subscribe(domain);
          return subRequest.success(function(data) {
            if (data.streamId != null) {
              return dfd.resolve(data);
            } else {
              return dfd.reject('invalid feed');
            }
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

  ReaderApi.prototype.unsubscribe = function(feedId) {
    var dfd, subRequest;
    var _this = this;
    dfd = $.Deferred();
    subRequest = this._unsubscribe(feedId);
    subRequest.success(function(data) {
      return dfd.resolve(data);
    });
    subRequest.fail(function(data) {
      var login;
      if (400 === data.status) {
        login = _this.login();
        login.done(function() {
          subRequest = _this._unsubscribe(feedId);
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
      }
    });
  };

  ReaderApi.prototype._unsubscribe = function(id) {
    var queryString;
    queryString = $.param({
      client: "Subscribe/" + Subscribe.version,
      s: id,
      ac: 'unsubscribe',
      T: this.token
    });
    return $.ajax({
      type: "POST",
      url: "" + this.host + "/reader/api/0/subscription/edit?" + queryString,
      headers: {
        "Content-Length": '0',
        "Authorization": "GoogleLogin auth=" + this.auth,
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
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
