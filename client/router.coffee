Backbone = require 'backbone'

class Router extends Backbone.Router
	routes:
		'':			'index'
		
	index: ->
		@navigate 'file/list', trigger: true
			
module.exports =
	Router: Router