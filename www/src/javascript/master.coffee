logPush = ->
  window.logHistory = window.logHistory || []
  window.logHistory.push(arguments)
  if window.console
    console.log( Array.prototype.slice.call(arguments) )


class ReaderApi
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



client = new ReaderApi
  username: 'bbsaid'
  password: 'Vhv94X(ZF;BWyW'


config =
  env: ->
    if window.location.hostname is 'subscribe.benubois.com.dev'
      'browser'
    else
      'device'
  host: ->
    if 'browser' is config.env()
      host = 'http://subscribe.benubois.com.dev/index.php'
    else
      host = 'https://www.google.com'

getAuth = (user, pass, cb) ->
  $.ajax
    url: "#{config.host()}/accounts/ClientLogin"
    data:
      "service": "reader"
      "Email": user
      "Passwd": pass
    success: (data) ->
      cb data.match(/Auth=(.*)/)[1]
    error: (data) ->
      alert('failed')

getToken = (auth, cb) ->
  $.ajax
    url: "#{config.host()}/reader/api/0/token"
    headers:
      "Content-type": "application/x-www-form-urlencoded"
      "Authorization": "GoogleLogin auth=#{auth}"
    success: (data) ->
      cb data

onDeviceReady = ->
  $('#button-login').on 'tap', () =>
    logPush 'something'
    user = $('input[name="username"]').val()
    pass = $('input[name="password"]').val()
    getAuth user, pass, (auth) ->
      getToken auth, (token) ->
        alert(token)

init =->
  if 'browser' is config.env()
    $(document).ready () ->
      onDeviceReady()
  else
  document.addEventListener("deviceready", onDeviceReady, false)

# getAuth msg, (auth) ->
#   getToken msg, auth, (token) ->
#     readerSubscribe msg, auth, token, domain
#
# getAuth = (msg, cb) ->
#   user = process.env.GOOGLE_USERNAME
#   pass = process.env.GOOGLE_PASSWORD
#   msg.http("https://www.google.com/accounts/ClientLogin")
#     .query
#       "service": "reader"
#       "Email": user
#       "Passwd": pass
#     .get() (err, res, body) ->
#       switch res.statusCode
#         when 200
#           cb body.match(/Auth=(.*)/)[1]
#         when 403
#           msg.send "You need to authenticate by setting the GOOGLE_USERNAME & GOOGLE_PASSWORD environment variables"
#         else
#           msg.send "Unable to get auth token, request returned with the status code: #{res.statusCode}"
#
# getToken = (msg, auth, cb) ->
#   msg.http('http://www.google.com/reader/api/0/token')
#     .headers
#       "Content-type": "application/x-www-form-urlencoded"
#       "Authorization": "GoogleLogin auth=#{auth}"
#     .get() (err, res, body) ->
#       cb body
#
# readerSubscribe = (msg, auth, token, domain) ->
#   msg.http('http://www.google.com/reader/api/0/subscription/quickadd?client=scroll')
#     .query
#       "quickadd": domain
#       "ac": 'subscribe'
#       "T": token
#     .headers
#       "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
#       "Content-Length": '0'
#       "Authorization": "GoogleLogin auth=#{auth}"
#     .post() (err, res, body) ->
#       switch res.statusCode
#         when 200
#           msg.send "You are now subscribing to #{domain}"
#         else
#           msg.send "Unable to subscribe, request returned with the status code: #{res.statusCode}"
#
#
# $.ajax({
#   url: "test.html",
#   context: document.body,
#   success: function(){
#       $(this).addClass("done");
#   }
# });