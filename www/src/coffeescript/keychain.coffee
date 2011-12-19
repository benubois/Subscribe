class Subscribe.Keychain
  authSet: (username, password) ->
    dfd = $.Deferred()
    
    auth = 
      username: username
      password: password
    
    string = JSON.stringify auth

    set = @set('auth', string)

    set.done (data) ->
      console.log data
      dfd.resolve data

    dfd.promise()

  authGet: () ->
    dfd = $.Deferred()
    get = @get('auth')
    get.done (data) ->
      dfd.resolve JSON.parse data
    get.fail ->
      dfd.reject 'error'
    dfd.promise()

  set: (key, value) ->
    dfd = $.Deferred()
    success = (key) ->
      dfd.resolve key
    fail = (key, error) ->
      dfd.reject error
    window.plugins.keychain.setForKey(key, value, 'com.benubois.Subscribe', success, fail)
    dfd.promise()

  get: (key) ->
    dfd = $.Deferred()
    success = (key, value) ->
      console.log 'error'
      console.log error
      dfd.resolve value
    fail = (key, error) ->
      dfd.reject error
    window.plugins.keychain.getForKey(key, 'com.benubois.Subscribe', success, fail)
    dfd.promise()

