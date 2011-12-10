
Subscribe.ReaderApi = (function() {

  function ReaderApi() {
    this.host = 'http://subscribe.benubois.com.dev/index.php';
    this.auth = null;
    this.token = null;
  }

  ReaderApi.prototype.request = function(domain) {
    var subRequest;
    subRequest = this.subscribe('http://www.pauljmartinez.com');
    return subRequest.fail(function(data) {
      var login;
      if (400 === data.status) {
        login = this.login();
        return login.done(function() {
          return subRequest = this.subscribe('http://www.pauljmartinez.com');
        });
      }
    });
  };

  ReaderApi.prototype.details = function() {
    return $.ajax({
      url: "" + this.host + "/reader/api/0/stream/details",
      data: {
        s: 'feed/http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml',
        tz: '-480',
        fetchTrends: 'false',
        output: 'json',
        client: 'Subscribe/1.0.0',
        ck: Math.round(new Date().getTime())
      },
      dataType: 'json',
      headers: {
        "Authorization": "GoogleLogin auth=" + this.auth
      },
      success: function(data) {
        return console.log(data);
      }
    });
  };

  ReaderApi.prototype.list = function() {
    return $.ajax({
      url: "" + this.host + "/reader/api/0/subscription/list",
      data: {
        output: "json",
        ck: Math.round(new Date().getTime() / 1000),
        client: 'Subscribe/1.0.0'
      },
      dataType: 'json',
      headers: {
        "Authorization": "GoogleLogin auth=" + this.auth
      },
      success: function(data) {
        var list;
        console.log(data);
        list = ich.subsciption_list_template(data);
        return $("#subsciption_list").html(list);
      }
    });
  };

  ReaderApi.prototype.subscribe = function(domain) {
    var queryString;
    queryString = $.param({
      'client': 'scroll',
      "quickadd": domain,
      "ac": 'subscribe',
      "T": this.token
    });
    return $.ajax({
      type: "POST",
      url: "" + this.host + "/reader/api/0/subscription/quickadd?" + queryString,
      headers: {
        "Content-Length": '0',
        "Authorization": "GoogleLogin auth=" + this.auth,
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
      },
      success: function(data) {
        return console.log(data);
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
        dfd.reject();
        return alert('Invalid username or password');
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
        return alert('Authentication error');
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
        dfd.resolve();
        return _this.token = data;
      },
      error: function(data) {
        return alert('Authentication error');
      }
    });
  };

  return ReaderApi;

})();
