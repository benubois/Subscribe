Subscribe.init =
  keychain: ->
    # Instantiate keychain
    Subscribe.debug 'init: initialized keychain'
    Subscribe.KeychainInst = new Subscribe.Keychain
  auth: ->
    Subscribe.debug 'init: get auth'
    get = Subscribe.KeychainInst.authGet()
    get.done (auth) -> 
      Subscribe.debug "init: get auth done auth:", auth
      Subscribe.googleLogin = auth
      Subscribe.action.login()
      jQT.goTo '#home'
    get.fail -> 
      Subscribe.debug "init: get auth failed"
      jQT.goTo '#login'

  loginDone: ->
    $(document).on 'subscribeLogin', ->
      Subscribe.debug 'Subscribe.init: loginDone'
      Subscribe.action.list()

  authFailure: ->
    $(document).on 'authFailure', ->
      Subscribe.debug 'init: auth failure'
      Subscribe.alert('Invalid username or password', 'Login Error', 'OK')
      jQT.goTo '#login'

  buttons: ->
    # Subscription detail
    $('#jqt').on 'tap', '.subscription', (e) ->
      Subscribe.debug 'init: subscription tapped'
      Subscribe.action.detail($(this))
      
    # Unsubscribe
    $('#jqt').on 'tap', '.unsubscribe', (e) ->
      Subscribe.debug 'init: unsubscribe tapped'
      Subscribe.action.unsubscribe($(this))
      
    # Refresh
    $('#jqt').on 'tap', '.refresh', (e) ->
      Subscribe.debug 'init: refresh tapped'
      Subscribe.action.list()
      
    # Add
    $('#jqt').on 'tap', '#add-subscription', (e) ->
      Subscribe.debug 'init: add-subscription tapped'
      Subscribe.action.subscribe()
      e.preventDefault()

  login: ->
    # Login
    $('#jqt').on 'tap', '.button-login', (e) ->
      Subscribe.debug "init: login tap"
      parent = $(this).parents('.current')
      usernameField = $('#field-username', parent)
      passwordField = $('#field-password', parent)

      username = usernameField.val()
      password = passwordField.val()
      
      if username is '' or password is ''
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
          Subscribe.debug 'login: login successful'
          Subscribe.action.savePassword(username, password)
          # Set up the client for the rest of the api to use
          Subscribe.ReaderApiInst = apiClient
          # Publish event other stuff can subscribe to
          $(document).trigger 'subscribeLogin'
          
          # Go to home screen
          jQT.goTo '#home'
          
          # Clear field values
          usernameField.val('')
          passwordField.val('')
        login.fail () ->
          Subscribe.alert('Invalid username or password', 'Login Error', 'OK')