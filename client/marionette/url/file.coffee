model = require '../../model.coffee'
controller = require '../controller/file.coffee'
vent = require '../../vent.coffee'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

reject = (err) ->
	vent.trigger 'show:msg', err, 'error'

class Router extends Backbone.Router
	routes:
		'file':				'list'
		'file/list':		'list'
		'file/icon':		'icon'
		'file/auth':		'auth'
		
	constructor: (opts = {}) ->
		@header = window.app.getRegion('header')
		@content = window.app.getRegion('content')
			
		@user = model.OGCIOUsers.me()
		@user.then (me) =>
			@collection = new model.Dir([], {path: me.homeDir()})
			@header.show new controller.NavBar collection: @collection
		super(opts)
			
	list: ->
		@user.then (me) =>
			fulfill = =>
				@content.show new controller.FileListView(collection: @collection)
			@collection.fetch().then fulfill, reject
		
	icon: ->
		@user.then (me) =>
			fulfill = =>
				@content.show new controller.FileIconListView(collection: @collection)
			@collection.fetch().then fulfill, reject
		
	auth: ->
		@user.then (me) =>
			permissions = new model.Permissions()
			fulfill = =>
				@content.show new controller.AuthListView(collection: permissions)
			permissions.fetch().then fulfill, reject
	
module.exports =
	Router:		Router