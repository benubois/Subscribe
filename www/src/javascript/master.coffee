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
      Subscribe.apiClient.list()
      Subscribe.apiClient.subscribe()

Subscribe.getLogin = ->
    dfd = $.Deferred()
    dfd.resolve
      username: 'subscribeapp.testing'
      password: 'hAMWCY2+Jfb7,q'
    dfd.promise()

init =->
  if 'browser' is Subscribe.env()
    $(document).ready () ->
      Subscribe.onDeviceReady()
  else
  document.addEventListener("deviceready", Subscribe.onDeviceReady, false)