controller = require "../controller/user.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })
lib = require '../lib.coffee'
ensurePermission = lib.ensurePermission
 
@include = ->

	@get '/api/user', bearer, ensurePermission('user:list'), ->
		controller.User.list(@request, @response)
		
	@post '/api/user', bearer, ensurePermission('user:create'), ->
		controller.User.create(@request, @response) 
		
	@get '/api/user/:id', bearer, ensurePermission('user:read'), ->
		controller.User.read(@request, @response)
		
	@put '/api/user/:id', bearer, ensurePermission('user:update'), ->
		controller.User.update(@request, @response)
		
	@del '/api/user/:id', bearer, ensurePermission('user:delete'), ->
		controller.User.delete(@request, @response)