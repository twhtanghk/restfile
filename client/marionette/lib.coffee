env = require '../env.coffee'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
vent = require '../vent.coffee'

class View extends Marionette.ItemView
	constructor: (opts) ->
		@router = opts.router
		super(opts)
		
	render: ->
		FlashView.getInstance().render()
		super()
		
class FlashView extends Marionette.ItemView
	className:	'alert'
	
	template: (data) =>
		header =
			success:	'Success!'
			info:		'Information!'
			warn:		'Warning!'
			error:		'Error!'
		if data.type?
			data.header = header[data.type]
		tmpl = """
			<button type="button" class="close" data-dismiss="alert">&times;</button>
			<h4><%= obj.header %></h4><%= obj.msg %>
		"""
		_.template tmpl, data
		
	constructor: (opts) ->
		type =
			success:	'bg-success'
			info:		'bg-info'
			warn:		'bg-warn'
			error:		'bg-danger'
		opts.className = "#{@className} #{type[opts.model.get('type')]}"
		super(opts)
		
	onRender: ->
		close = =>
			@$el.hide =>
				@remove()
		setTimeout close, env.flash.timeout

class ModalView extends Marionette.ItemView
	id:			'modal'
	className:	'modal'
	
	template: (data) =>
		tmpl = """
		  <div class="modal-dialog">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		        <h4 class="modal-title"></h4>
		      </div>
		      <div class="modal-body">
		      </div>
		    </div>
		  </div>
		"""
		_.template tmpl, data
		
	constructor: (opts = {}) ->
		super(opts)
		vent.on 'show:modal', (msg) =>
			@$el.html @template(msg)
			@$el.find('.modal-title').append(msg.header)
			@$el.find('.modal-body').append(msg.body)
			@$el.modal('show')
		vent.on 'hide:modal', =>
			@$el.modal('hide')
		
	@getInstance: ->
		@_instance ?= new ModalView()
	
class IFrameView extends Marionette.ItemView
	tagName:	'iframe'
		
	className:	'hide'
	
	@getInstance: ->
		@_instance ?= new IFrameView()
		
class ModelView extends Marionette.ItemView
	template: (data) =>
		"<div class='model'>#{ModelView.show(@model)}</div>"

	@show: (obj) ->
		if _.isNaN(obj) or _.isNull(obj) or _.isUndefined(obj)
			return ''
			
		ret = ''
		
		if typeof obj == 'object'
		
			if obj instanceof Backbone.Collection			# Collection
				obj.each (value, key, list) ->
					ret += """
						<div class='field'>
							#{ModelView.show value}
						</div>
					""" 
				
			else if obj instanceof Backbone.Model			# Model
				view = obj.pick obj.showFields()			# show attributes only if defined in model.showFields()
				_.each view, (value, key, list) ->
					ret += """
						<div class='field'>
							<label class='key'>#{obj.schema[key].title}</label>
							#{ModelView.show value}
						</div>
					"""
					
			else if _.isArray obj
				_.each obj, (value) ->
					ret += """
						<div class='field'>
							#{ModelView.show value}
						</div>
					""" 
					
			else if _.isDate obj
				ret += obj.toLocaleString()
									
			else	 										# Plain Object
				_.each obj, (value, key, list) ->
					ret += """
						<div class='field'>
							<label class='key'>#{key}</label>
							#{ModelView.show value}
						</div>
					"""
			
		else												# Primitive Type
			ret += "<span class='value'>#{obj}</span>"
		
		return ret
		
ctag = (map, key, tmpl) ->
	return if _.isUndefined(map[key]) then '' else _.template tmpl, map

###
	opts:	icon
###
class Icon extends Marionette.ItemView
	tagName:	'span'
	
	className:	'glyphicon'
	
	template: (data) ->
		''
		
	constructor: (opts = {}) ->
		if opts.icon
			opts.className = "#{@className} glyphicon-#{opts.icon}"
		super(opts)
	 
###
	opts.model:	type, title, data-toggle, data-placement, appendIcon, prependIcon
###
class Btn extends Marionette.ItemView
	tagName:	'a'
	
	className:	'btn btn-default'
	
	attributes:
		'data-toggle':		'tooltip'
		'data-placement':	'bottom'
		
	template: (data) =>
		"#{ctag(data, 'text', '<%= obj.text %>')}"
		
	constructor: (opts = {}) ->
		_.extend @, _.pick(opts.model.attributes, 'id', 'template')
		if opts.model.get('className')?
			opts.className = "#{@className} #{opts.model.get('className')}"
		_.extend @attributes, _.pick(opts.model.attributes, 'title', 'type', 'data-toggle', 'data-placement', 'href')
		_.defaults @attributes, href: '#'
		super(opts)
		
	onRender: ->
		if @model.attributes.prependIcon?
			icon = new Icon icon: @model.attributes.prependIcon
			@$el.prepend icon.render().el
		if @model.attributes.appendIcon?
			icon = new Icon icon: @model.attributes.appendIcon
			@$el.append icon.render().el

###
	id:				id
	collection:		collection of button view
###
class BtnGrp extends Marionette.CollectionView
	className:	'btn-group'
	
	childView:	Btn
	
	constructor: (opts = {}) ->
		if opts.className
			opts.className = "#{@className} #{opts.className}"
		super(opts)
	
###
	id:				id
	className:		input className
	value:			input default value
	placeholder:	input placeholder
###
class Input extends Marionette.ItemView
	className:	'input-group'
	
	template: (data) ->
		tmpl = """
			#{ctag(data, 'prependIcon', '<span class="input-group-addon glyphicon glyphicon-<%= obj.prependIcon %>"></span>')}
			<input id="<%= obj.id %>" type="text" class="form-control <%= obj.className %>" value="<%= obj.value %>" placeholder="<%= obj.placeholder %>">
			#{ctag(data, 'appendIcon', '<span class="input-group-addon glyphicon glyphicon-<%= obj.appendIcon %>"></span>')}
		"""
		_.template tmpl, data
		
###
model:
	id: 	'File'
	items:	
		'New File': 
			id:		'fileCreate'
			href:	'#file/create'
			class:	'fileCreate'
		'New Folder': 
			id:		'fileMkdir'
			href:	'#file/mkdir'
			class:	'fileMkdir'
###
class Dropdown extends Marionette.ItemView
	tagName:	'ul'
	
	className:	'dropdown-menu'
	
	template: (data) ->
		tmpl = """
				<% _.each(obj.items, function(value, key) { %>
			    <li>
			    	<a id="<%= value.id %>" class="<%= value.class %>" href="<%= value.href %>">
			    		<%= key %>
			    	</a>
			    </li>
			    <% }) %>
		"""
		_.template tmpl, data
		
class PageView extends Marionette.ItemView
	template: (data) -> 
		"""
			<div id='flash'></div>
			<div id='content'></div>
			<div id='modal' class="modal fade"></div>
		"""
	
	onRender: ->
		FlashView.getInstance()
		ModalView.getInstance()
		
module.exports =
	View:		View
	FlashView:	FlashView
	IFrameView:	IFrameView
	ModelView:	ModelView
	ModalView:	ModalView
	Icon:		Icon
	Btn:		Btn
	BtnGrp:		BtnGrp
	Input:		Input
	Dropdown:	Dropdown
	PageView:	PageView