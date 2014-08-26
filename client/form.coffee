Backbone = require 'backbone'
require 'backbone-forms'
require 'backbone-forms/distribution/backbone-forms'
require '../public/js/backbone.bootstrap-modal'
require 'backbone-forms/distribution/editors/list'
require '../public/templates/bootstrap'

# list editor with default value
class DList extends Backbone.Form.editors.List
	events:
		'click [data-action="add"]': 'newDefault'
		 
	constructor: (opts) ->
		super(opts)
		@data = opts.schema.data
	
	newDefault: (event) ->
		event.preventDefault()
		@addItem(@data().toJSON(), true)
		
Backbone.Form.editors.DList = DList

# select editor with object value
class OSelect extends Backbone.Form.editors.Select
	getValue: (value) ->
		id = super()
		@schema.options.findWhere _id: id
		
Backbone.Form.editors.OSelect = OSelect