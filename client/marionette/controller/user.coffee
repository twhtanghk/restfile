_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
lib = require '../lib.coffee'
View = lib.View
ModelView = lib.ModelView
model = require '../../model.coffee'
User = model.User
vent = require '../../vent.coffee'

class UserCreateView extends View
	template: (data) =>
		@form.render().el
			
	events:
		'submit form#userCreate': 'create'
		
	onBeforeRender: ->
		@form = new Backbone.Form
			model: 		@model
			template: 	_.template """
					<form id='userCreate' class="form-horizontal">
						 <div data-fieldsets>
						 </div>
						 <button type='submit' class='btn btn-default'>
						 	<span class="glyphicon glyphicon-floppy-disk"></span>
						 	Create
						 </button>
					</form>
				"""
			fields:		@model.fields()
		
	create: ->
		success = (model, response, options) =>
			@router.listView.once 'render', ->
				vent.trigger 'show:msg', 'User has been successfully created', 'success'
			@router.navigate 'user/list', trigger: true
			
		error = (model, xhr, options) ->
			vent.trigger 'show:msg', "#{xhr.statusText} #{xhr.responseText}", 'error'
			
		valid = @form.commit()
		if _.isUndefined(valid)
			@form.model.save {}, {success: success, error: error}
		return false

class UserReadView extends View
	template: (data) =>
		"""
			<a class='btn btn-default' href='#user/update/#{@model.id}'>
				<span class="glyphicon glyphicon-edit"></span>
				Update
			</a>
			<a class='btn btn-default' href='#confirmDel' role='button' data-toggle="modal">
				<span class="glyphicon glyphicon-remove"></span>
				Delete
			</a>
			<div id='confirmDel' class="modal fade">
				<div class="modal-dialog">
  					<div class="modal-content">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal">&times;</button>
							<h4 class='modal-title'>Delete User</h4>
						</div>
						<div class="modal-body">
							<p>Confirm to delete?</p>
						</div>
						<div class="modal-footer">
							<button type='button' class="btn btn-default" data-dismiss='modal'>Cancel</button>
							<button type='button' id='userDelete' class="btn btn-primary" data-dismiss='modal'>
								<span class="glyphicon glyphicon-remove"></span>
								Delete
							</button>
						</div>
					</div>
				</div>
			</div>
			<div class='data'>
			</div>
		"""
		
	events:
		'click button#userDelete': 'remove'
		
	onRender: ->
		view = new lib.ModelView {el: 'div.data', model: @model}
		view.render()
		
	remove: -> 
		success = (model, response, options) =>
			@router.listView.once 'render', ->
				vent.trigger 'show:msg', 'User has been successfully deleted', 'success'
			@router.navigate 'user/list', trigger: true
			
		error = (model, xhr, options) ->
			vent.trigger 'show:msg', "#{xhr.statusText} #{xhr.responseText}", 'error'
			
		@$el.find("#confirmDel.modal").modal('hide').on 'hidden.bs.modal', =>
			@model.destroy {success: success, error: error}		
		
class UserUpdateView extends View
	template: (data) =>
		@form.render().el
			
	events:
		'submit form#userUpdate': 'update'
		
	onBeforeRender: ->
		@form = new Backbone.Form
			model: 		@model
			template: 	_.template """
					<form id='userUpdate' class="form-horizontal">
						 <div data-fieldsets>
						 </div>
						 <button type='submit' class='btn btn-default'>
						 	<span class="glyphicon glyphicon-edit"></span>
						 	Update
						 </button>
					</form>
				"""
			fields:	@model.fields()
			
	update: ->
		success = (model, response, options) =>
			@router.listView.once 'render', ->
				vent.trigger 'show:msg', 'User has been successfully updated', 'success'
			@router.navigate 'user/list', trigger: true
			
		error = (model, xhr, options) ->
			vent.trigger 'show:msg', "#{xhr.statusText} #{xhr.responseText}", 'error'
			
		valid = @form.commit()
		if _.isUndefined(valid)
			@form.model.save {}, {success: success, error: error}
		return false
		
class UserListView extends View
	template: (data) =>
		container = """
			<div>
				<div class="left-inner-addon form-inline search">
					<i class="glyphicon glyphicon-search"></i>
					<input class="form-control" id="search" type="text">
				</div>
				<a href='#user/create' class='btn btn-default pull-right'>
					<span class="glyphicon glyphicon-plus"></span>
					Create
				</a>
			</div>
			<ul class='data-list'><%= obj.liNodes %></ul>
		"""
		element = "<li><a href='#user/read/<%= obj.id %>'><%= obj.toString() %></a></li>"
		liNodes = ''
		@collection.each (user, key, list) ->
			liNodes += _.template element, user			
		return _.template container, {liNodes: liNodes}

class UserView extends Marionette.ItemView
	template: (data) =>
		"""
			<td><a>#{@model.toString()}</a></td>
			<td><a>#{@model.get('Email')}</td>
			<td></td>
		"""
			
	events:
		'click':				'select'
		
	tagName: 'tr'
	
	className: 'user-sel'
	
	select: (event) ->
		@model.toggleSelect()
		@$el.toggleClass('selected', @model.get('selected'))
		
class UserSearchView extends Marionette.CompositeView

	template: (data) =>
		"""
			<table>
				<thead>
					<tr>
						<th class='name'>Name</th>
						<th class='email'>Email</th>
						<th class='tags'>Tags</th>
					</tr>
				</thead>
			</table>
		"""
	
	itemView: UserView
	
	itemViewContainer: 'table'
	
	searchTag: =>
		container = """
			<div class="left-inner-addon form-inline search">
				<i class="glyphicon glyphicon-search"></i>
				<input class="form-control user-search" type="text">
			</div>
			<div id='result'><%=obj.result%></div>
		"""
		
	resultTag: =>
		container = """
			<ul class='user-list'>
				<%=obj.liNodes%>			</ul>
			<ul class="user-pager pager">
				<li class="previous <%=obj.collection.hasPrevious() ? '' : 'disabled'%>">
					<a href="#">&laquo; prev</a>
				</li>
				<li class="next <%=obj.collection.hasNext() ? '' : 'disabled'%>">
					<a href="#">next &raquo;</a>
				</li>
			</ul>
		"""
		element = """
			<li class='user-sel' id='<%=obj.get('_id')%>'>
				<%=obj.toString()%></a>
			</li>
		"""
		liNodes = ''
		@collection.each (item, key, list) ->
			liNodes += _.template element, item			
		return _.template container, {collection: @collection, liNodes: liNodes}
				
	events:
		'input .user-search':				'search'
		'click .user-list li':				'select'
		'click .user-pager li.previous':	'prev'
		'click .user-pager li.next':		'next'		

	collectionEvents:
		'add':				'refresh'
		'change':			'refresh'
		'remove':			'refresh'
		'reset':			'refresh'
		'sync':				'refresh'

	refresh: ->
		@$el.find('div#result').html @resultTag()
		
	search: (event) ->
		@collection.search $(event.target).val()
		
	select: (event) ->
		selecteduser = @collection.findWhere({_id: $(event.target).attr('id')})
		selecteduser.toggleSelect()
				
	prev: (event) ->
		if $(event.currentTarget).hasClass('disabled')
			return false
		@collection.getPreviousPage()
		return false
		
	next: (event) ->
		if $(event.currentTarget).hasClass('disabled')
			return false
		@collection.getNextPage()
		return false

module.exports =	
	UserListView: 	UserListView
	UserCreateView: UserCreateView
	UserReadView: 	UserReadView
	UserUpdateView: UserUpdateView
	UserSearchView: UserSearchView