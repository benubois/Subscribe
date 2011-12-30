Subscribe.action =
  savePassword: (username, password) ->
    Subscribe.debug "init: Saving password to keychain"
    keychain = new Subscribe.Keychain
    set = keychain.authSet username, password
    set.done (auth) ->
      Subscribe.debug "init: set done auth: #{auth}"
    set.fail ->
      Subscribe.debug 'failed keychain'
    
  list: ->
    Subscribe.debug 'Subscribe.action: list'
    request = Subscribe.ReaderApiInst.list()
    request.done (data) ->
      Subscribe.subscriptions = data
      if 0 is Subscribe.subscriptions.subscriptions.length
        Subscribe.subscriptions.condition_no_subscriptions = true
        Subscribe.subscriptions.condition_has_subscriptions = false
      else
        Subscribe.subscriptions.condition_no_subscriptions = false
        Subscribe.subscriptions.condition_has_subscriptions = true
      Subscribe.subscriptions.subscriptions = _.map(Subscribe.subscriptions.subscriptions, Subscribe.addUrl);
      content = ich.subscriptions_list(Subscribe.subscriptions)
      $("#subscriptions").html content  
    request.fail (data) ->
      console.log data  

  login: ->
    Subscribe.debug 'Subscribe.action: login'
    apiClient = new Subscribe.ReaderApi
    login = apiClient.login()
    login.done () ->
      Subscribe.debug 'Subscribe.action: login done'
      # Set up the client for the rest of the api to use
      Subscribe.ReaderApiInst = apiClient
      # Publish event other stuff can subscribe to
      $(document).trigger 'subscribeLogin'

  subscribe: ->
    urlField = $('#url')
    url = urlField.val()
    
    if url is ''
      Subscribe.debug "init: username and password validation failed"
      Subscribe.alert('You must enter a url', 'Subscribe Error', 'OK')
      return false
    else
      request = Subscribe.ReaderApiInst.subscribe(url)
      # Request succeeded, add data to detail template
      request.done (data) ->
        # Update the list
        Subscribe.action.list()
        
        # Go home
        jQT.goTo '#home'
        
        # Clear value
        urlField.val('')
      request.fail (data) ->
        Subscribe.alert('Subscribe failed', 'Subscribe Error', 'OK')

  unsubscribe: (el) ->
    feedId = el.data('feed-id')
    request = Subscribe.ReaderApiInst.unsubscribe(feedId)
    # Request succeeded, add data to detail template
    request.done (data) ->
      Subscribe.action.removeSubscription feedId 
    # unsubscribe request failed
    # TODO add error info
    request.fail (data) ->
      Subscribe.alert('Unsubscribe failed', 'Subscribe Error', 'OK')
  
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