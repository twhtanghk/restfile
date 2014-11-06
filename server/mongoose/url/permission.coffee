env = require '../../../env.coffee'
controller = require "../controller/permission.coffee"
middleware = require '../../../middleware.coffee'
model = require '../../../model.coffee'

filter = (params) ->
	params.search || {}
			
pagination = (params) ->
	page = if params.page then params.page else 1
	limit = if params.per_page then params.per_page else env.pageSize
	ret =
		skip:	(page - 1) * limit
		limit:	limit
	return ret
	
order = (params) ->
	params.order_by || model.Permission.ordering_fields()

@include = ->

	@get '/api/permission', middleware.rest.user, ->
		handler = middleware.rest.handler(@response)
		controller.Permission.list(filter(@request.query), pagination(@request.query), order(@request.query)).then handler.fulfill, handler.reject
		
	@post '/api/permission', middleware.rest.user, ->
		handler = middleware.rest.handler(@response)
		controller.Permission.create(@request.user, @request.body).then handler.fulfill, handler.reject
		
	@del '/api/permission/:id', middleware.rest.user, ->
		handler = middleware.rest.handler(@response)
		id = @request.params.id
		controller.Permission.delete(@request.user, id).then handler.fulfill, handler.reject