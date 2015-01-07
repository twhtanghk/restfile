env = require './env.coffee'
Backbone = require 'backbone'
require './form.coffee'
Marionette = require 'backbone.marionette'
router = require './router.coffee'
user = require './marionette/url/user.coffee'
file = require './marionette/url/file.coffee'
model = require './model.coffee'
view = require './marionette/controller/file.coffee'
lib = require './marionette/lib.coffee'
vent = require './vent.coffee'

class App extends Marionette.Application
	constructor: (opts = {}) ->
		super(opts)
		
		@addRegions header: '.header'
		@addRegions content: '.content'
		
		# configure to acquire bearer token for all api call from oauth2 server
		jso_configure 
			oauth2:
				client_id:		env.oauth2.clientID
				authorization:	env.oauth2.authUrl

		sync = Backbone.sync
		Backbone.sync = (method, model, opts) ->
			error = opts.error
			opts.error = (resp) ->
				error(resp)
				vent.trigger 'show:msg', resp.responseJSON.error, 'error'
			sync method, model, opts
				
		Backbone.ajax = (settings) ->
			_.extend settings,
				jso_provider: 	'oauth2'
				error:			(xhr, status, err) ->
					if status != '200'
						vent.error err
			jso_ensureTokens oauth2: env.oauth2.scope
			Backbone.$.oajax(settings)
		
		success = (user) =>
			@user = user
			@router = new router.Router()
			@fileRouter = new file.Router(el: 'body')
			
			Backbone.history.start()
			
		error = ->
			alert 'Unauthorized access'
		
		model.OGCIOUsers.me().then success, error
		
module.exports =
	App: App