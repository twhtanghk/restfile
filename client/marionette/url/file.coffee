model = require '../../model.coffee'
controller = require '../controller/file.coffee'
vent = require '../../vent.coffee'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

class Router extends Backbone.Router
	routes:
		'file/list':		'list'
		
	constructor: (opts = {}) ->
		@user = model.OGCIOUsers.me()
		@user.then (me) =>
			@collection = new model.Dir([], {path: me.homeDir()})
			@listView = new controller.FileSearchView {el: opts.el, collection: @collection, router: @}
		super(opts)
			
	list: ->
		@user.then (me) =>
			@listView.render()
		
module.exports =
	Router:		Router