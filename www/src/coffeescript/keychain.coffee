class Subscribe.Keychain
  authSet: (username, password) ->
    Subscribe.debug "Keychain: Setting username: #{username} and password: #{password}"

    dfd = $.Deferred()
    # Create auth object
    auth = 
      username: escape username
      password: escape password
    
    Subscribe.debug "Keychain: auth: ", auth
    
    # Format as json string
    string = JSON.stringify auth

    # Save json to keychain
    set = @set 'google_login', string
    
    # Resolse promise with authkey
    set.done (data) ->
      Subscribe.debug "Keychain: authSet done data: #{data}"
      dfd.resolve data
    
    # Return promise
    dfd.promise()

  authGet: () ->
    Subscribe.debug "Keychain: authGet called"

    dfd = $.Deferred()
    
    if Subscribe.googleLogin
      Subscribe.debug "Keychain: Already have googleLogin, just returning that"
      dfd.resolve Subscribe.googleLogin
    else
      # Get auth from keychain
      get = @get 'google_login'
      get.done (data) ->
        Subscribe.debug "Keychain: authGet done data: #{data}"
        auth = JSON.parse unescape(data)
        auth.username = unescape(auth.username)
        auth.password = unescape(auth.password)

        dfd.resolve auth
      get.fail ->
        Subscribe.debug "Keychain: authGet fail"
        dfd.reject()
    dfd.promise()

  set: (key, value) ->
    dfd = $.Deferred()
    success = (key) ->
      Subscribe.debug "Keychain: set success key: #{key}"
      dfd.resolve key
    fail = ->
      Subscribe.debug "Keychain: set fail"
      dfd.reject()
    if Subscribe.env() is 'device'
      # Escape the value before inserting into the keychain
      value = escape value
      window.plugins.keychain.setForKey(key, value, 'com.benubois.Subscribe', success, fail)
    else    
      callback = -> success key
      setTimeout callback, 10
    dfd.promise()

  get: (key) ->
    Subscribe.debug "Keychain: get called key #{key}"
    dfd = $.Deferred()
    success = (key, value) ->
      Subscribe.debug "Keychain: get success key: #{key}"
      dfd.resolve unescape value
    fail = ->
      Subscribe.debug "Keychain: get fail"
      dfd.reject()
    if Subscribe.env() is 'device'
      window.plugins.keychain.getForKey(key, 'com.benubois.Subscribe', success, fail)
    else    
      callback = -> success 'auth', '%7B%22username%22%3A%22subscribeapp.testing%22%2C%22password%22%3A%221passw0rd4%22%7D'
      setTimeout callback, 10
    dfd.promise()
