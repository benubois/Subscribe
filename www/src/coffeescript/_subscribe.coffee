Subscribe =
  log: ->
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
    if 'browser' is Subscribe.env()
      host = 'http://subscribe.benubois.com.dev/index.php'
    else
      host = 'https://www.google.com'
  onDeviceReady: ->
    $.each Subscribe.init, (i, item) -> 
      item();
