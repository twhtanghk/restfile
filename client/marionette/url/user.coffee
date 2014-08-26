model = require '../../model.coffee'
controller = require '../controller/user.coffee'
vent = require '../../vent.coffee'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

class Router extends Backbone.Router
	routes:
		'user/list':		'list'
		'user/create':		'create'
		'user/read/:id':	'read'
		'user/update/:id':	'update'
		
	constructor: (opts = {}) ->
		@collection = new model.Users()
		@listView = new controller.UserSearchView {el: opts.el, collection: @collection, router: @}
		@createView = new controller.UserCreateView {el: opts.el, router: @}
		@readView = new controller.UserReadView {el: opts.el, router: @}
		@updateView = new controller.UserUpdateView {el: opts.el, router: @}
	
		vent.on 'user:selected', (user) =>
			@read user.id
			
		super(opts)
			
	list: ->
		@listView.collection.getFirstPage()
		@listView.render()
			
	create: ->
		@createView.model = new model.User({}, collection: @collection)
		@createView.render()
		
	read: (id) ->
		@readView.model = new model.User {_id: id}, {collection: new model.Users()}
		@readView.model.fetch success: =>
			@readView.render()
		
	update: (id) ->
		@updateView.model = new model.User {_id: id}, {collection: new model.Users()}
		@updateView.model.fetch success: =>
			@updateView.render()
		
module.exports =
	Router:		Router