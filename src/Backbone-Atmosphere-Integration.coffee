socket = $.atmosphere
Backbone = this.Backbone
_ = this._

findAll = (model) ->
  
  request =
    url: model.url,
    contentType : "application/json",
    logLevel : 'debug',
    transport : 'websocket'

  request.onOpen = (response) -> 
    console.log("onOpen: " + response)
    
  request.onMessage = (response) -> 
  
    message = $.parseJSON(response.responseBody)

    console.log(message.event)

    if message.event?
      switch message.event
        when "CREATE"
          model.add(message.entity)
        when "UPDATE"
          model.add(message.entity)
        when "DELETE"
          model.remove(message.entity)  
    else
      model.add(message)
      
  request.onError = (response) ->
    console.log("error: " + response)
  subSocket = socket.subscribe(request)
    
Backbone.webserviceSync = (method, model, options, error) ->

  switch method
    when "read"
      if model.id?
        find(model)
      else
        findAll(model)
    when "create" then
    when "update" then
    when "delete" then

Backbone.overridenSync = Backbone.sync

Backbone.sync = (method, model, options = {}, error) ->
  if method is "read" and (model?.ws || model?.collection?.ws)
    return Backbone.webserviceSync(method, model, options, error)
  else
    #creations must be synchronous to ensure the id is set on the existing model
    #before it is added via a websocket.
    if method == "create" then options.async = false
    
    return Backbone.overridenSync(method, model, options, error)
