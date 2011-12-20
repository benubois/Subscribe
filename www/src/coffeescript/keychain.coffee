class Subscribe.Keychain
  authSet: (username, password) ->
    Subscribe.debug "Keychain: Setting username: #{username} and password: #{password}"

    dfd = $.Deferred()
    # Create auth object
    auth = 
      username: username
      password: password
    
    # Format as json string
    string = JSON.stringify auth
    
    # Save json to keychain
    set = @set 'auth', string
    
    # Resolse promise with authkey
    set.done (data) ->
      Subscribe.debug "Keychain: authSet done data: #{data}"
      dfd.resolve data
    
    # Return promise
    dfd.promise()

  authGet: () ->
    Subscribe.debug "Keychain: authGet called"

    dfd = $.Deferred()
    
    # Get auth from keychain
    get = @get 'auth'
    get.done (data) ->
      Subscribe.debug "Keychain: authGet done data: #{data}"
      dfd.resolve JSON.parse data
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
      dfd.resolve value
    fail = ->
      Subscribe.debug "Keychain: get fail"
      dfd.reject()
    if Subscribe.env() is 'device'
      window.plugins.keychain.getForKey(key, 'com.benubois.Subscribe', success, fail)
    else    
      callback = -> success 'auth', '{"username":"subscribeapp.testing","password":"hAMWCY2+Jfb7,q"}'
      setTimeout callback, 10
    dfd.promise()
