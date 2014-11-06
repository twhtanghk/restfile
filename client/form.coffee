Backbone = require 'backbone'
require 'backbone-forms'
require 'backbone-forms/distribution/backbone-forms'
require '../public/js/backbone.bootstrap-modal'
require 'backbone-forms/distribution/editors/list'
require '../public/templates/bootstrap'
require 'select2'
require 'underscore'

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

class Select extends Backbone.Form.editors.Select 
	render: ->
		_.delay =>
			@$el.select2(placeholder: @schema.title)
		super()
		
Backbone.Form.editors.Select = Select

class MSelect extends Backbone.Form.editors.Select 
	attributes : {multiple : 'multiple'}
		
	render: ->
		_.delay =>
			@$el.select2(if @schema.title then placeholder: @schema.title else {})
		super()
		
	setValue : (values) ->
		if not _.isArray(values)
			values = [values];
		@$el.val(values)
		
Backbone.Form.editors.MSelect = MSelect

# select editor with object value
class OSelect extends Backbone.Form.editors.Select
	getValue: (value) ->
		id = super()
		@schema.options.findWhere _id: id
		
Backbone.Form.editors.OSelect = OSelect

class FieldOnly extends Backbone.Form.Field
	template: (data) ->
		_.template """
			<div class="form-group field-<%= key %>">
				<div>
					<span data-editor></span>
					<p class="help-block" data-error></p>
					<p class="help-block"><%= help %></p>
				</div>
			</div>
		""", data
	
Backbone.Form.FieldOnly = FieldOnly