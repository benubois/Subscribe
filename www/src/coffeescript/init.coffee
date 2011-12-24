Subscribe.init =
  keychain: ->
    # Instantiate keychain
    Subscribe.KeychainInst = new Subscribe.Keychain
  auth: ->
    Subscribe.log 'init: get auth'
    get = Subscribe.KeychainInst.authGet()
    get.done (auth) -> 
      Subscribe.log "init: get auth done auth:", auth
      Subscribe.googleLogin = auth
      Subscribe.action.login();
      jQT.goTo '#home'
    get.fail -> 
      Subscribe.log "init: get auth failed"
      jQT.goTo '#login'

  loginDone: ->
    $(document).on 'subscribeLogin', ->
      Subscribe.log 'Subscribe.init: loginDone'
      Subscribe.action.list()

  buttons: ->
    # Subscription detail
    $('#jqt').on 'tap', '.subscription', (e) ->
      Subscribe.action.detail($(this))
      
    # Unsubscribe
    $('#jqt').on 'tap', '.unsubscribe', (e) ->
      Subscribe.action.unsubscribe($(this))
      
    # Refresh
    $('#jqt').on 'tap', '.refresh', (e) ->
      Subscribe.action.list()

  login: ->
    # Login
    $('#jqt').on 'tap', '.button-login', (e) ->
      Subscribe.debug "init: login tap"
      parent = $(this).parents('.current')
      username = $('#field-username', parent).val();
      password = $('#field-password', parent).val();
      if username is '' || password is ''
        Subscribe.debug "init: username and password validation failed"
        Subscribe.alert('You must enter a username and password', 'Login Error', 'OK')
        return false
      else
        Subscribe.debug "login: username and password given, trying login"
        Subscribe.googleLogin = 
          username: username
          password: password
        apiClient = new Subscribe.ReaderApi
        login = apiClient.login()
        login.done () ->
          Subscribe.log 'login: login successful'
          Subscribe.action.savePassword(username, password)
          # Set up the client for the rest of the api to use
          Subscribe.ReaderApiInst = apiClient
          # Publish event other stuff can subscribe to
          $(document).trigger 'subscribeLogin';
          jQT.goTo '#home'
        login.fail () ->
          Subscribe.alert('Invalid username or password', 'Login Error', 'OK')
      

Subscribe.action =
  savePassword: (username, password) ->
    Subscribe.debug "init: Saving password to keychain"
    keychain = new Subscribe.Keychain
    set = keychain.authSet username, password
    set.done (auth) ->
      Subscribe.debug "init: set done auth: #{auth}"
    set.fail ->
      Subscribe.log 'failed keychain'
    
  list: ->
    Subscribe.log 'Subscribe.action: list'
    request = Subscribe.ReaderApiInst.list()
    request.done (data) ->
      if 0 is data.subscriptions.length
        data.condition_no_subscriptions = true
        data.condition_has_subscriptions = false
      else
        data.condition_no_subscriptions = false
        data.condition_has_subscriptions = true
      content = ich.subscriptions_list(data)
      $("#subscriptions").html content  
    request.fail (data) ->
      console.log data  

  login: ->
    Subscribe.log 'Subscribe.action: login'
    apiClient = new Subscribe.ReaderApi
    login = apiClient.login()
    login.done () ->
      Subscribe.log 'Subscribe.action: login done'
      # Set up the client for the rest of the api to use
      Subscribe.ReaderApiInst = apiClient
      # Publish event other stuff can subscribe to
      $(document).trigger 'subscribeLogin';

  subscribe: ->
    url = $('#url').val()
    request = Subscribe.ReaderApiInst.subscribe(url)
    # Request succeeded, add data to detail template
    request.done (data) ->
      # Update the list
      Subscribe.action.list()
      # unsubscribe request failed
    # TODO add error info
    request.fail (data) ->
      Subscribe.alert('subscribe failed')

  unsubscribe: (el) ->
    feedId = el.data('feed-id')
    request = Subscribe.ReaderApiInst.unsubscribe(feedId)
    # Request succeeded, add data to detail template
    request.done (data) ->
      Subscribe.action.removeSubscription feedId 
    # unsubscribe request failed
    # TODO add error info
    request.fail (data) ->
      Subscribe.alert('unsubscribe failed')
  
  removeSubscription: (id) ->
    $('#subscriptions').find('li a').each ->
      if $(this).data('feed-id') is id
        $(this).parents('li').remove()
    
  detail: (el) ->
    feedId = el.data('feed-id')
    # Prepare title object
    title = 
      title: el.text()
    # Add title to detail template
    $("#title").html ich.title_template(title)  
    # Get feed details
    request = Subscribe.ReaderApiInst.details(feedId)
    # Request succeeded, add data to detail template
    request.done (data) ->
      data.id = feedId
      $("#details").html ich.details_template(data)  
    # Detail request failed
    # TODO add error info
    request.fail (data) ->
      console.log 'detail fail'    

Subscribe.load =->
  if 'browser' is Subscribe.env()
    $(document).ready () ->
      Subscribe.onDeviceReady()
  else
    document.addEventListener("deviceready", Subscribe.onDeviceReady, false)
