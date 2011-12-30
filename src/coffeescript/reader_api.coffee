class Subscribe.ReaderApi
  constructor: () ->
    @host = Subscribe.host()
    @auth = null
    @token = null

  subscribe: (domain) ->
    dfd = $.Deferred()
    
    subRequest = @_subscribe (domain)
    
    subRequest.success (data) ->
      if data.streamId?
        # get details successful, resolve with info
        dfd.resolve data
      else
        # Update alert contents with unsuccessful request info
        dfd.reject 'invalid feed'
    
    subRequest.fail (data) =>
      if 400 is data.status

        # If token is invalid, get a new one and try again
        login = @login()
        login.done () =>
          subRequest = @_subscribe (domain)
          
          subRequest.success (data) ->
            if data.streamId?
              # get details successful, resolve with info
              dfd.resolve data
            else
              # Update alert contents with unsuccessful request info
              dfd.reject 'invalid feed'
        login.fail () ->
          dfd.reject
          alert 'Couldn’t log in after 2 tries'
    
    dfd.promise()
  
  details: (feedId) ->
    dfd = $.Deferred()
    
    subRequest = @_details (feedId)
    
    subRequest.success (data) ->
      # get details successful, resolve with info
      dfd.resolve data
    
    subRequest.fail (data) =>
      if 400 is data.status

        # If token is invalid, get a new one and try again
        login = @login()
        login.done () =>
          subRequest = @_details (feedId)
          
          subRequest.success (data) ->
            # get details successful, resolve with info
            dfd.resolve data
        login.fail () ->
          dfd.reject
          alert 'Couldn’t log in after 2 tries'
    
    dfd.promise()
  
  list: ->
    dfd = $.Deferred()
    
    subRequest = @_list()
    
    subRequest.success (data) ->
      # get details successful, resolve with info
      dfd.resolve data
    
    subRequest.fail (data) =>
      if 400 is data.status

        # If token is invalid, get a new one and try again
        login = @login()
        login.done () =>
          subRequest = @_list()
          
          subRequest.success (data) ->
            # get details successful, resolve with info
            dfd.resolve data
        login.fail () ->
          dfd.reject
          alert 'Couldn’t log in after 2 tries'
    
    dfd.promise()
  
  unsubscribe: (feedId) ->
    dfd = $.Deferred()
    
    subRequest = @_unsubscribe (feedId)
    
    subRequest.success (data) ->
      # get details successful, resolve with info
      dfd.resolve data
    
    subRequest.fail (data) =>
      if 400 is data.status

        # If token is invalid, get a new one and try again
        login = @login()
        login.done () =>
          subRequest = @_unsubscribe (feedId)
          
          subRequest.success (data) ->
            # get details successful, resolve with info
            dfd.resolve data
        login.fail () ->
          dfd.reject
          alert 'Couldn’t log in after 2 tries'
    
    dfd.promise()
  
  _details: (feedId) ->
    $.ajax
      url: "#{@host}/reader/api/0/stream/details"
      data:
        s: feedId
        tz: '-480'
        fetchTrends: 'false'
        output: 'json'
        client: "Subscribe/#{Subscribe.version}"
        ck: Math.round new Date().getTime()
      dataType: 'json'
      headers:
        "Authorization": "GoogleLogin auth=#{@auth}"

  _list: () ->
    $.ajax
      url: "#{@host}/reader/api/0/subscription/list"
      data:
        output: "json"
        ck: Math.round new Date().getTime() / 1000
        client: "Subscribe/#{Subscribe.version}"
      dataType: 'json'
      headers:
        "Authorization": "GoogleLogin auth=#{@auth}"
      error: ->
        $(document).trigger 'authFailure'

  _subscribe: (domain) ->
    
    queryString = $.param
      client: "Subscribe/#{Subscribe.version}"
      quickadd: domain
      ac: 'subscribe'
      T: @token

    $.ajax
      type: "POST"
      url: "#{@host}/reader/api/0/subscription/quickadd?#{queryString}"
      dataType: 'json'
      headers:
        "Content-Length": '0'
        "Authorization": "GoogleLogin auth=#{@auth}"
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
  
  _unsubscribe: (id) ->
    
    queryString = $.param
      client: "Subscribe/#{Subscribe.version}"
      s: id
      ac: 'unsubscribe'
      T: @token

    $.ajax
      type: "POST"
      url: "#{@host}/reader/api/0/subscription/edit?#{queryString}"
      headers:
        "Content-Length": '0'
        "Authorization": "GoogleLogin auth=#{@auth}"
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
  
  # PRIVATE METHODS
  login: () ->
    dfd = $.Deferred()
    
    # Get Google login info from keychain
    credentials = Subscribe.KeychainInst.authGet()
    
    # When the login info returns, complete the authentication process
    credentials.done (login) =>
      
      # Get authorization
      authRequest = @getAuth login.username, login.password
      authRequest.success (data) =>
        
        # Get token
        tokenRequest = @getToken @auth, dfd
      authRequest.fail (data) =>
        # Auth failed, callers can use login.fail
        dfd.reject()
    
    # Return the defered promise so callers can use login.done()
    dfd.promise()

  getAuth: (username, password) ->
    
    queryString = $.param
      service: "reader"
    
    $.ajax
      type: "POST"
      url: "#{@host}/accounts/ClientLogin?#{queryString}"
      data:
        "Email": username
        "Passwd": password
      success: (data) =>
        @auth = data.match(/Auth=(.*)/)[1]
      error: (data) =>
        Subscribe.debug data
        jQT.goTo '#login'
        Subscribe.debug('readerApi.getAuth: Invalid username or password')
        

  getToken: (auth, dfd) ->
    $.ajax
      url: "#{@host}/reader/api/0/token"
      headers:
        "Content-type": "application/x-www-form-urlencoded"
        "Authorization": "GoogleLogin auth=#{auth}"
      success: (data) =>
        @token = data
        dfd.resolve()
      error: (data) =>
        alert('Authentication error')
