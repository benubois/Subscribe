Subscribe =
  logPush: ->
    window.logHistory = window.logHistory || []
    window.logHistory.push(arguments)
    if window.console
      console.log( Array.prototype.slice.call(arguments) )
  env: ->
    if window.location.hostname is 'subscribe.benubois.com.dev'
      'browser'
    else
      'device'
  host: ->
    if 'browser' is Subscribe.config.env()
      host = 'http://subscribe.benubois.com.dev/index.php'
    else
      host = 'https://www.google.com'
  onDeviceReady: ->
    $.each Subscribe.init, (i, item) -> 
      item();
      
class Subscribe.api
  subscribe: (domain) ->
    subRequest = client.subscribe 'http://www.pauljmartinez.com'
    subRequest.fail (data) ->
      if 400 is data.status
        
        # If token is invalid, get a new one and try again
        login = client.login()
        login.done () ->
          subRequest = client.subscribe 'http://www.pauljmartinez.com'

class Subscribe.ReaderApi
  constructor: () ->
    @host = 'http://subscribe.benubois.com.dev/index.php'
    @auth = null
    @token = null
  
  details: () ->
    $.ajax
      url: "#{@host}/reader/api/0/stream/details"
      data:
        s: 'feed/http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml'
        tz: '-480'
        fetchTrends: 'false'
        output: 'json'
        client: 'Subscribe/1.0.0'
        ck: Math.round new Date().getTime()
      dataType: 'json'
      headers:
        "Authorization": "GoogleLogin auth=#{@auth}"
      success: (data) ->
        console.log data
        # list = ich.subsciption_list_template(data)
        # $("#subsciption_list").html list

  list: () ->
    $.ajax
      url: "#{@host}/reader/api/0/subscription/list"
      data:
        output: "json"
        ck: Math.round new Date().getTime() / 1000
        client: 'Subscribe/1.0.0'
      dataType: 'json'
      headers:
        "Authorization": "GoogleLogin auth=#{@auth}"
      success: (data) ->
        console.log data
        list = ich.subsciption_list_template(data)
        $("#subsciption_list").html list
  
  subscribe: (domain) ->
    
    queryString = $.param
      'client': 'scroll'
      "quickadd": domain
      "ac": 'subscribe'
      "T": @token

    $.ajax
      type: "POST"
      url: "#{@host}/reader/api/0/subscription/quickadd?#{queryString}"
      headers:
        "Content-Length": '0'
        "Authorization": "GoogleLogin auth=#{@auth}"
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
      success: (data) ->
        console.log data
  
  # PRIVATE METHODS
  login: () ->
    dfd = $.Deferred()
    
    # Get Google login info from keychain
    credentials = Subscribe.getLogin()
    
    # When the login info returns, complete the authentication process
    credentials.done (login) =>
      
      # Get authorization
      authRequest = @getAuth login.username, login.password
      authRequest.success (data) =>
        
        # Get token
        tokenRequest = @getToken @auth, dfd
      authRequest.error (data) =>
        # Auth failed, callers can use login.fail
        dfd.reject()
        alert('Invalid username or password')
    
    # Return the defered promise so callers can use login.done()
    dfd.promise()

  getAuth: (username, password) ->
    $.ajax
      url: "#{@host}/accounts/ClientLogin"
      data:
        "service": "reader"
        "Email": username
        "Passwd": password
      success: (data) =>
        @auth = data.match(/Auth=(.*)/)[1]
      error: (data) =>
        alert('Authentication error')

  getToken: (auth, dfd) ->
    $.ajax
      url: "#{@host}/reader/api/0/token"
      headers:
        "Content-type": "application/x-www-form-urlencoded"
        "Authorization": "GoogleLogin auth=#{auth}"
      success: (data) =>
        dfd.resolve()
        @token = data
      error: (data) =>
        alert('Authentication error')

Subscribe.init =
  login: ->
    console.log 'login'
    apiClient = new Subscribe.ReaderApi
    login = apiClient.login()
    login.done () ->
      # Set up the client for the rest of the api to use
      Subscribe.apiClient = apiClient
      
      # Publish event other stuff can subscribe to
      $(document).trigger 'subscribeLogin';
  loginDone: ->
    $(document).on 'subscribeLogin', ->
      console.log 'logged in'
      Subscribe.apiClient.list()

Subscribe.getLogin = ->
    dfd = $.Deferred()
    dfd.resolve
      username: 'bbsaid'
      password: 'Vhv94X(ZF;BWyW'
    dfd.promise()

init =->
  if 'browser' is Subscribe.env()
    $(document).ready () ->
      Subscribe.onDeviceReady()
  else
  document.addEventListener("deviceready", Subscribe.onDeviceReady, false)