Subscribe.init =
  login: ->
    apiClient = new Subscribe.ReaderApi
    login = apiClient.login()
    login.done () ->
      # Set up the client for the rest of the api to use
      Subscribe.apiClient = apiClient
      
      # Publish event other stuff can subscribe to
      $(document).trigger 'subscribeLogin';
  loginDone: ->
    $(document).on 'subscribeLogin', ->
      Subscribe.apiClient.list()
  subscriptionTouch: ->
    $('#jqt').on 'tap', '.subscription', (e) ->
      Subscribe.action.detail($(this))

Subscribe.action =
  subscribe: ->
    url = $('#url').val()
    Subscribe.apiClient.request(url)
  detail: (feed) ->
    feedId = feed.attr('id')
    
    # Prepare title object
    title = 
      title: feed.text()
    # Add title to detail template
    $("#title").html ich.title_template(title)  
    
    # Get feed details
    request = Subscribe.apiClient.details(feedId)
    
    request.done (data) ->
      $("#details").html ich.details_template(data)  
      

    request.fail (data) ->
      console.log 'detail fail'
    

Subscribe.load =->
  if 'browser' is Subscribe.env()
    $(document).ready () ->
      Subscribe.onDeviceReady()
  else
  document.addEventListener("deviceready", Subscribe.onDeviceReady, false)
