class Subscribe.ReaderApi
  constructor: () ->
    @host = Subscribe.host()
    @auth = null
    @token = null

  subscribe: (domain) ->
    subRequest = @_subscribe domain
    subRequest.fail (data) =>
      if 400 is data.status

        # If token is invalid, get a new one and try again
        login = @login()
        login.done () =>
          subRequest = @_subscribe domain
        login.fail () ->
          alert 'Couldn’t log in after 2 tries'
  
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
      success: (data) ->
        # list = ich.subsciption_list_template(data)
        # $("#subsciption_list").html list

  list: () ->
    $.ajax
      url: "#{@host}/reader/api/0/subscription/list"
      data:
        output: "json"
        ck: Math.round new Date().getTime() / 1000
        client: "Subscribe/#{Subscribe.version}"
      dataType: 'json'
      headers:
        "Authorization": "GoogleLogin auth=#{@auth}"
      success: (data) ->
        if 0 is data.subscriptions.length
          data.condition_no_subscriptions = true
          data.condition_has_subscriptions = false
        else
          data.condition_no_subscriptions = false
          data.condition_has_subscriptions = true

        content = ich.subscriptions_list(data)
        $("#subscriptions").html content  
      error: (data) ->
        console.log data  
  
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
      success: (data) ->
        console.log data
        if data.streamId?
          # Subscription was successful, remove the alert
          alert 'subscription success'
        else
          # Update alert contents with unsuccessful request info
          console.log 'no subscription'
  
  # PRIVATE METHODS
  login: () ->
    dfd = $.Deferred()
    
    # Get Google login info from keychain
    credentials = Subscribe.getLogin()
    
    # When the login info returns, complete the authentication process
    credentials.done (login) =>
      
      # Get authorization
      authRequest = @getAuth login.username, login.password
      authRequest.success (data) =>
        
        # Get token
        tokenRequest = @getToken @auth, dfd
      authRequest.error (data) =>
        # Auth failed, callers can use login.fail
        dfd.reject()
    
    # Return the defered promise so callers can use login.done()
    dfd.promise()

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
        Subscribe.log data
        alert('Invalid username or password')

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
