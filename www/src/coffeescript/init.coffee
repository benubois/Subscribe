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
      
Subscribe.action =
  subscribe: ->
    url = $('#url').val()
    Subscribe.apiClient.request(url)
      

Subscribe.load =->
  if 'browser' is Subscribe.env()
    $(document).ready () ->
      Subscribe.onDeviceReady()
  else
  document.addEventListener("deviceready", Subscribe.onDeviceReady, false)
