var Subscribe;

Subscribe = {
  version: '1.0.0',
  debugMode: true,
  debug: function(message) {
    if (Subscribe.debugMode) return Subscribe.log(message);
  },
  log: function() {
    window.Subscribe.logHistory = window.Subscribe.logHistory || [];
    window.Subscribe.logHistory.push(arguments);
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
  alert: function(message, title, action) {
    var complete;
    if (Subscribe.env() === 'device') {
      console.log('should alert');
      complete = function() {
        return console.log('complete');
      };
      return navigator.notification.alert(message, complete, title, action);
    } else {
      return alert(message);
    }
  },
  onDeviceReady: function() {
    return $.each(Subscribe.init, function(i, item) {
      return item();
    });
  }
};

Subscribe.init = {
  auth: function() {
    var get, keychain;
    Subscribe.log('init: get auth');
    keychain = new Subscribe.Keychain;
    get = keychain.authGet();
    get.done(function(auth) {
      Subscribe.log("init: get auth done auth:", auth);
      Subscribe.log(jQT);
      return jQT.goTo('#home');
    });
    return get.fail(function() {
      Subscribe.log("init: get auth failed");
      return jQT.goTo('#login');
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
  },
  login: function() {
    return $('#jqt').on('tap', '#button-login', function(e) {
      var keychain, password, set, username;
      Subscribe.debug("init: login tap");
      username = $('#field-username').val();
      password = $('#field-password').val();
      if (username === '' || password === '') {
        Subscribe.debug("init: username and password validation failed");
        Subscribe.alert('You must enter a username and password', 'Login Error', 'OK');
        return false;
      } else {
        Subscribe.debug("init: Saving password to keychain");
        keychain = new Subscribe.Keychain;
        set = keychain.authSet(username, password);
        set.done(function(auth) {
          return Subscribe.debug("init: set done auth: " + auth);
        });
        return set.fail(function() {
          return Subscribe.log('failed keychain');
        });
      }
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
  login: function() {
    var apiClient, login;
    apiClient = new Subscribe.ReaderApi;
    login = apiClient.login();
    return login.done(function() {
      Subscribe.apiClient = apiClient;
      return $(document).trigger('subscribeLogin');
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
      return Subscribe.alert('subscribe failed');
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
      return Subscribe.alert('unsubscribe failed');
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
    return $(document).ready(function() {
      return Subscribe.onDeviceReady();
    });
  } else {
    return document.addEventListener("deviceready", Subscribe.onDeviceReady, false);
  }
};

Subscribe.Keychain = (function() {

  function Keychain() {}

  Keychain.prototype.authSet = function(username, password) {
    var auth, dfd, set, string;
    Subscribe.debug("Keychain: Setting username: " + username + " and password: " + password);
    dfd = $.Deferred();
    auth = {
      username: username,
      password: password
    };
    string = JSON.stringify(auth);
    set = this.set('auth', string);
    set.done(function(data) {
      Subscribe.debug("Keychain: authSet done data: " + data);
      return dfd.resolve(data);
    });
    return dfd.promise();
  };

  Keychain.prototype.authGet = function() {
    var dfd, get;
    Subscribe.debug("Keychain: authGet called");
    dfd = $.Deferred();
    get = this.get('auth');
    get.done(function(data) {
      Subscribe.debug("Keychain: authGet done data: " + data);
      return dfd.resolve(JSON.parse(data));
    });
    get.fail(function() {
      Subscribe.debug("Keychain: authGet fail");
      return dfd.reject();
    });
    return dfd.promise();
  };

  Keychain.prototype.set = function(key, value) {
    var callback, dfd, fail, success;
    dfd = $.Deferred();
    success = function(key) {
      Subscribe.debug("Keychain: set success key: " + key);
      return dfd.resolve(key);
    };
    fail = function() {
      Subscribe.debug("Keychain: set fail");
      return dfd.reject();
    };
    if (Subscribe.env() === 'device') {
      window.plugins.keychain.setForKey(key, value, 'com.benubois.Subscribe', success, fail);
    } else {
      callback = function() {
        return success(key);
      };
      setTimeout(callback, 10);
    }
    return dfd.promise();
  };

  Keychain.prototype.get = function(key) {
    var callback, dfd, fail, success;
    Subscribe.debug("Keychain: get called key " + key);
    dfd = $.Deferred();
    success = function(key, value) {
      Subscribe.debug("Keychain: get success key: " + key);
      return dfd.resolve(value);
    };
    fail = function() {
      Subscribe.debug("Keychain: get fail");
      return dfd.reject();
    };
    if (Subscribe.env() === 'device') {
      window.plugins.keychain.getForKey(key, 'com.benubois.Subscribe', success, fail);
    } else {
      callback = function() {
        return success('auth', '{"username":"subscribeapp.testing","password":"hAMWCY2+Jfb7,q"}');
      };
      setTimeout(callback, 10);
    }
    return dfd.promise();
  };

  return Keychain;

})();

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
    var queryString;
    var _this = this;
    queryString = $.param({
      service: "reader"
    });
    return $.ajax({
      type: "POST",
      url: "" + this.host + "/accounts/ClientLogin?" + queryString,
      data: {
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
