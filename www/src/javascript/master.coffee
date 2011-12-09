Subscribe =
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
  logPush: ->
    window.logHistory = window.logHistory || []
    window.logHistory.push(arguments)
    if window.console
      console.log( Array.prototype.slice.call(arguments) )
  onDeviceReady: ->
    $.each Subscribe.init, (i, item) -> 
  	  item();
      
Subscribe.init =
  env: ->
    console.log 'init'


class Subscribe.ReaderApi
  constructor: (options) ->
    @host = 'http://subscribe.benubois.com.dev/index.php'
    @auth = null
    @token = null
    @login options
  
  readerSubscribe: (domain) ->
    $.ajax
      url: "#{@host}/accounts/ClientLogin"
      data:
        "quickadd": @domain
        "ac": 'subscribe'
        "T": @token
      headers:
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
        "Content-Length": '0'
        "Authorization": "GoogleLogin auth=#{@auth}"
      success: (data) =>
        console.log successfully subscribed
      error: (data) =>
        console.log subscription error
  
  # PRIVATE METHODS
  login: (options) ->
    authRequest = @getAuth options.username, options.password
  
    authRequest.success (data) =>
      tokenRequest = @getToken @auth
    authRequest.error (data) =>
      alert('Invalid username or password')
  
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

  getToken: (auth) ->
    $.ajax
      url: "#{@host}/reader/api/0/token"
      headers:
        "Content-type": "application/x-www-form-urlencoded"
        "Authorization": "GoogleLogin auth=#{auth}"
      success: (data) =>
        @token = data
      error: (data) =>
        alert('Authentication error')

init =->
  if 'browser' is Subscribe.env()
    $(document).ready () ->
      Subscribe.onDeviceReady()
  else
  document.addEventListener("deviceready", Subscribe.onDeviceReady, false)