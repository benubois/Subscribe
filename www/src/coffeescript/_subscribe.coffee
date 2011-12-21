Subscribe =
  googleLogin: null
  version: '1.0.0'
  debugMode: true
  debug: (message) ->
    Subscribe.log message if Subscribe.debugMode
  log: ->
    window.Subscribe.logHistory = window.Subscribe.logHistory || []
    window.Subscribe.logHistory.push(arguments)
    if window.console
      console.log( Array.prototype.slice.call(arguments) )
  env: ->
    if window.location.hostname is 'subscribe.benubois.com.dev'
      'browser'
    else
      'device'
  host: ->
    if 'browser' is Subscribe.env()
      host = 'http://subscribe.benubois.com.dev/index.php'
    else
      host = 'https://www.google.com'
  alert: (message, title, action) ->
      if Subscribe.env() is 'device'
        console.log 'should alert'
        callback = ->
          console.log 'complete'
        navigator.notification.alert message, callback, title, action
      else
        alert message
  onDeviceReady: ->
    Subscribe.log 'Subscribe: onDeviceReady'
    $.each Subscribe.init, (i, item) -> 
      item();
