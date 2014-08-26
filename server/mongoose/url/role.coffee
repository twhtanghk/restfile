controller = require "../controller/role.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })
lib = require '../lib.coffee'
ensurePermission = lib.ensurePermission
 
@include = ->

	@get '/api/role', bearer, ensurePermission('role:list'), ->
		controller.Role.list(@request, @response)
		
	@post '/api/role', bearer, ensurePermission('role:create'), ->
		controller.Role.create(@request, @response) 
		
	@get '/api/role/:id', bearer, ensurePermission('role:read'), ->
		controller.Role.read(@request, @response)
		
	@put '/api/role/:id', bearer, ensurePermission('role:update'), ->
		controller.Role.update(@request, @response)
		
	@del '/api/role/:id', bearer, ensurePermission('role:delete'), ->
		controller.Role.delete(@request, @response)