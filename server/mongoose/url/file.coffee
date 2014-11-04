env = require '../../../env.coffee'
path = require 'path'
controller = require "../controller/file.coffee"
passport = require 'passport'
lib = require '../lib.coffee'
newHome = lib.newHome
ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
ensurePermission = lib.ensurePermission
middleware = require '../../../middleware.coffee'
 
authURL = path.join(env.path, env.oauth2.authURL)
bearer = middleware.rest.user

@include = ->

	path = new RegExp("^/((?:[^/]+/)*[^/]*)$") 
	
	dir = new RegExp "^/api/file/((?:[^/]+/)*)$" 
	file = new RegExp "^/api/file/((?:[^/]+/)*[^/]+)$"
	api = new RegExp "^/api/file/((?:[^/]+/)*[^/]*)$"

	@post api, bearer, newHome(), ensurePermission('file:create'), ->
		controller.File.create(@request, @response) 
		
	@get api, bearer, newHome(), ensurePermission('file:read'), ->
		controller.File.read(@request, @response)
			
	@put api, bearer, newHome(), ensurePermission('file:update'), ->
		controller.File.update(@request, @response)
		
	@del api, bearer, newHome(), ensurePermission('file:delete'), ->
		controller.File.delete(@request, @response)
		
	@get path, ensureLoggedIn(authURL), ensurePermission('file:read'), ->
		controller.File.open(@request, @response)