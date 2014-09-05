env = require '../../env.coffee'
Promise = require 'promise'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
lib = require '../lib.coffee'
View = lib.View
ModelView = lib.ModelView
scope =
	model: require '../../model.coffee'
File = scope.model.File
vent = require '../../vent.coffee'
path = require 'path'
userController = require './user.coffee'

class DirInput extends Marionette.Layout
	id:			'cwd'
	
	tagName:	'form'
	
	className:	'navbar-form navbar-left'
	
	template: (data) =>
		@input.render().el.outerHTML
		
	events:
		'submit':								'ignore'
		'click span.glyphicon-circle-arrow-up':	'up'
		'click span.glyphicon-refresh':			'refresh'
		'change input#cwd':						'cd'
		
	collectionEvents:
		'sync':	'path'
			
	constructor: (opts = {}) ->
		super(opts)
		model = new Backbone.Model {id: @id, placeholder: 'Directory', value: @collection.path, prependIcon: 'circle-arrow-up', appendIcon: 'refresh'}
		@input = new lib.Input model: model
		
	ignore: (event) ->
		event.preventDefault()
	
	path: ->
		@$('input#cwd').val(@collection.path)
		
	up: (event) ->
		event.preventDefault()
		@collection.up()
		
	refresh: (event) ->
		event.preventDefault()
		@collection.refresh()
		
	cd: (event) ->
		event.preventDefault()
		@collection.cd @$('input#cwd').val() 
	
class SearchInput extends Marionette.Layout
	id:			'search'
	
	tagName:	'form'
	
	className:	'navbar-form navbar-right'
	
	template: (data) =>
		@input.render().el.outerHTML
		
	events:
		'submit':						'ignore'
		'click span.glyphicon-search':	'search'
		'input input#search':			'search'
		
	constructor: (opts = {}) ->
		super(opts)
		model = new Backbone.Model {id: @id, placeholder: 'Search', value: '', prependIcon: 'search'}
		@input = new lib.Input model: model
		
	ignore: (event) ->
		event.preventDefault()
		
	search: (event) ->
		event.preventDefault()
		@collection.search @$('input#search').val()
				
class NavMenu extends Marionette.Layout
	id:			'menu'
	
	tagName:	'ul'
	
	className:	'nav navbar-nav'
	
	template: (data) =>
		tmpl = """
			<li id='<%= obj.id %>' class="dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown">
					<%= obj.id %> <b class="caret"></b>
					<%= obj.menu %>
				</a>
			</li>
		"""
		ret = ''
		@collection.each (menu) ->
			view = new lib.Dropdown model: menu
			ret += _.template tmpl, {id: menu.id, menu: view.render().el.outerHTML}
		return ret
		
	constructor: (opts = {}) ->
		extra = if _.isUndefined opts.className then '' else opts.className 
		opts.className = "#{@className} #{extra}" 
		super(opts)
			
class RightMenu extends NavMenu
	events:
		'click #logout':	'logout'
		
	constructor: (opts = {}) ->
		opts.className = 'navbar-right'
		super(opts)
		
	render: =>	
		icon = new lib.Icon {icon: 'user'}
		scope.model.OGCIOUsers.me().then (me) =>
			user = new Backbone.Model
				id: 	"#{icon.render().el.outerHTML}#{me.get('username')}"
				items:	
					'Logout': 
						id:		'logout'
						href:	"#{env.path}/auth/logout"
						class:	''
			@collection = new Backbone.Collection [user]
			super()
	
	logout: ->
		jso_wipe()
		return true
			
class NavBar extends Marionette.Layout
	tagName:	'nav'
	
	className:	'navbar navbar-default'
	
	regions:
		dir:	'#dir'
		menu:	'#menu'
		search:	'#search'
		user:	'#user'
		
	template: (data) ->
		"""
			<div class="container-fluid">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#menu">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</button>
					<a id='home' class="navbar-brand" href="#">File</a>
				</div>
				
				<div id='menu' class="collapse navbar-collapse">
					<div id='dir' />
					<div id='user' />
					<div id='search' />
				</div>
			</div>
		"""	
	
	events:
		'click #home':						'home'
		'click #newfile':					'newfile'
		'click #newdir':					'newdir'
		'click #edit':						'edit'
		'click #addTags':					'addTags'
		'click #removeTags':				'removeTags'
		'change input.file-upload':			'upload'
		'click #download':					'download'
		'click #selectAll':					'selectAll'
		'click #deselectAll':				'deselectAll'
		'click #icon':						'icon'
		'click #list':						'list'
		'click #trash':						'trash'
		'click #UserTagView':				'UserTagView'
		'click #addUserTags':				'addUserTags'
		
	constructor: (opts) ->
		home = new Backbone.Model
			id:				'home'
			prependIcon:	'home'
			title:			'home'
		newfile = new Backbone.Model
			id:				'newfile'
			prependIcon:	'plus'
			appendIcon:		'file'
			title:			'new file'
		newdir = new Backbone.Model
			id:				'newdir'
			prependIcon:	'plus'
			appendIcon:		'folder-open'
			title:			'new folder'
		edit = new Backbone.Model
			id:				'edit'
			prependIcon:	'edit'
			title:			'edit'
		addTags = new Backbone.Model
			id:				'addTags'
			prependIcon:	'plus'
			appendIcon:		'tags'
			title:			'add tags'
		removeTags = new Backbone.Model
			id:				'removeTags'
			prependIcon:	'minus'
			appendIcon:		'tags'
			title:			'remove tags'
		upload = new Backbone.Model
			className:		'btn-file'
			prependIcon: 	'cloud-upload'
			title: 			'upload'
			template: 		(data) ->
				"<input class='file-upload' name='file' type='file' multiple='multiple' />"
		download = new Backbone.Model
			id:				'download'
			prependIcon:	'cloud-download'
			title:			'download'
		selectAll = new Backbone.Model
			id:				'selectAll'
			prependIcon:	'check'
			title:			'select all'
		deselectAll = new Backbone.Model
			id:				'deselectAll'
			prependIcon:	'unchecked'
			title:			'deselect all'
		icon = new Backbone.Model
			id:				'icon'
			prependIcon: 	'th'
			title: 			'icon'
		list = new Backbone.Model
			id:				'list'
			prependIcon: 	'th-list'
			title: 			'list'
		trash = new Backbone.Model
			id:				'trash'
			prependIcon: 	'trash'
			title: 			'delete'
		UserTagView = new Backbone.Model
			id:				'UserTagView'
			appendIcon:		'user'
			title: 			'change User View'			
		addUserTags = new Backbone.Model
			id:				'addUserTags'
			prependIcon:	'plus'
			appendIcon:		'pushpin'
			title: 			'create user tag'
					
		btns = [home, newfile, newdir, addTags, removeTags, edit, upload, download, selectAll, deselectAll, icon, list, trash, UserTagView, addUserTags]
		@btns = new lib.BtnGrp	className: 'navbar-btn', collection: new Backbone.Collection btns   
		
		@views =
			dir:	new DirInput(collection: opts.collection)
			search:	new SearchInput(collection: opts.collection)
			user:	new RightMenu(collection: opts.collection)
		super(opts)
		
	onRender: ->
		@dir.show @views.dir
		@search.show @views.search
		@user.show @views.user
		@$('div.collapse').append @btns.render().el
		
	home: (event) ->
		event.preventDefault()
		@collection.home()
		
	newfile: (event) ->
		event.preventDefault()
		$(event.target).parent().removeClass('open')
		file = new File {path: path.join(@collection.cwd(), env.file.newfile)}, {collection: @collection}
		file.save {}, success: =>
			@collection.refresh()
		
	newdir: (event) ->
		event.preventDefault()
		$(event.target).parent().removeClass('open')
		file = new File {path: "#{path.join(@collection.cwd(), env.file.newdir)}/"}, {collection: @collection}
		file.save {}, success: =>
			@collection.refresh()
	
	edit: (event) ->
		event.preventDefault()
		if @collection.selected().length == 0
			return
		collection = @collection
		schema = {}
		data = {}
		_.each @collection.selected(), (file) ->
			schema[file.basename()] = {type: 'Text', validators: ['required'], title: file.basename()}
			data[file.basename()] = file.basename()
			schema["#{file.basename()} tags"] = {type: 'Text', title: "#{file.basename()} tags"}
			data["#{file.basename()} tags"] = file.get('tags').join(', ')
		form = new Backbone.Form 
			schema: 	schema
			data: 		data
			template: 	_.template """
				<form id='edit' class="form-horizontal">
					 <div data-fieldsets>
					 </div>
					 <button type='submit' class='btn btn-default'>
					 	<span class="glyphicon glyphicon-floppy-disk"></span>
					 	Edit
					 </button>
					 <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
				</form>
			"""
			events:
				submit: (event) ->
					event.preventDefault()
					newname = _.values form.getValue()
					done = ->
						vent.trigger 'hide:modal'
						collection.refresh()
					io = _.map collection.selected(), (file, index) ->
						newname = form.getEditor(file.basename()).getValue()
						newtags = form.getEditor("#{file.basename()} tags").getValue()
						file.rename newname
						file.set 'tags', _.map newtags.split(','), (tag) ->
							tag.trim()
						file.save()
					Promise.all(io).then(done, done)
		vent.trigger 'show:modal', {header: 'Rename File', body: form.render().el}

	addTags: (event) ->
		event.preventDefault()
		if @collection.selected().length == 0
			return
		collection = @collection
		form = new Backbone.Form
			schema:
				tags:	{ type:	'Text', editorAttrs: {placeholder: 'security relevant, restricted, ..., for IT security team'} }
			template:	_.template """
				<form id='tags' class="form-horizontal">
					 <div data-fieldsets>
					 </div>
					 <button type='submit' class='btn btn-default'>
					 	<span class="glyphicon glyphicon-floppy-disk"></span>
					 	Add Tag
					 </button>
					 <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
				</form>
			"""
			events:
				submit: (event) ->
					event.preventDefault()
					newtags = form.getEditor('tags').getValue().split(',')
					newtags = _.map newtags, (tag) ->
						tag.trim()
					done = ->
						vent.trigger 'hide:modal'
						collection.refresh()
					io = _.map collection.selected(), (file, index) ->
						_.map newtags, (tag) ->
							file.addTag(tag)
						file.save()
					Promise.all(io).then(done, done)
		vent.trigger 'show:modal', {header: 'Tag File', body: form.render().el}
	
	removeTags: (event) ->
		event.preventDefault()
		if @collection.selected().length == 0
			return
		collection = @collection
		form = new Backbone.Form
			schema:
				tags:	{ type:	'Text', editorAttrs: {placeholder: 'security relevant, restricted, ..., for IT security team'} }
			template:	_.template """
				<form id='tags' class="form-horizontal">
					 <div data-fieldsets>
					 </div>
					 <button type='submit' class='btn btn-default'>
					 	<span class="glyphicon glyphicon-floppy-disk"></span>
					 	Remove Tag
					 </button>
					 <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
				</form>
			"""
			events:
				submit: (event) ->
					event.preventDefault()
					newtags = form.getEditor('tags').getValue().split(',')
					newtags = _.map newtags, (tag) ->
						tag.trim()
					done = ->
						vent.trigger 'hide:modal'
						collection.refresh()
					io = _.map collection.selected(), (file, index) ->
						_.map newtags, (tag) ->
							file.removeTag(tag)
						file.save()
					Promise.all(io).then(done, done)
		vent.trigger 'show:modal', {header: 'Tag File', body: form.render().el}
	
	upload: (event) ->
		event.preventDefault()
		done = =>
			$(event.target).val('')
			@collection.refresh()
		io = _.map event.target.files, (localfile) =>
			newpath = path.join @collection.cwd(), localfile.name
			file = @collection.findWhere({path: newpath})
			if not file 
				file = new File {path: newpath}, {collection: @collection}
			file.save(file: localfile)
		Promise.all(io).then(done, done)		
	
	download: (event) ->
		event.preventDefault()
		_.each @collection.selected(), (file) ->
			file.fetch()
	
	selectAll: (event) ->
		event.preventDefault()
		@collection.selectAll()
	
	deselectAll: (event) ->
		event.preventDefault()
		@collection.deselectAll()
			
	icon: (event) ->
		event.preventDefault()
		vent.trigger 'icon:file' 
		
	list: (event) ->
		event.preventDefault()
		vent.trigger 'list:file'
	
	trash: (event) ->
		event.preventDefault()
		if @collection.selected().length == 0
			return
		collection = @collection
		files = _.map @collection.selected(), (file) -> 
			file.basename() 
		form = new Backbone.Form
			template:	_.template """
				<form class="form-horizontal">
					 <p>
					 	Confirm to delete #{files.join(', ')}?
					 </p>
					 <button type='submit' class='btn btn-default'>
					 	<span class="glyphicon glyphicon-remove"></span>
					 	Delete
					 </button>
					 <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
				</form>
			"""
			events:
				submit: (event) ->
					event.preventDefault()
					io = _.map collection.selected(), (file) ->
						file.destroy()
					done = ->
						vent.trigger 'hide:modal'
						collection.refresh()
					Promise.all(io).then(done, done)						
		vent.trigger 'show:modal', {header: 'Delete File', body: form.render().el}

	UserTagView: (event) ->
		event.preventDefault()
		vent.trigger 'list:user'
		
	addUserTags: (event) ->
		event.preventDefault()

		form = new Backbone.Form
			schema:
				tags:	{ type:	'Text', editorAttrs: {placeholder: 'P21, admin, ..., for IT security team'} }
			template:	_.template """
				<form id='tags' class="form-horizontal">
					 <div data-fieldsets>
					 </div>
					 <button type='submit' class='btn btn-default'>
					 	<span class="glyphicon glyphicon-floppy-disk"></span>
					 	Add Tag
					 </button>
					 <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
				</form>
			"""
			events:
				submit: (event) ->
					event.preventDefault()
					alert "addusertags"
					newtags = form.getEditor('tags').getValue().split(',')
					newtags = _.map newtags, (tag) ->
						tag.trim()
		vent.trigger 'show:modal', {header: 'Tag User', body: form.render().el}
		
class FileView extends Marionette.ItemView
	tagName:	'tr'
	
	className:	'file img-rounded'
	
	tag: ->
		tmpl = """
			<img src='#{@model.iconUrl()}' alt='<%= obj.basename() %>'>
			<a href="<%= obj.accessUrl() %>" target='_blank'>
				<%= obj.toString() %>
			</a>
		"""
		_.template tmpl, @model
		
	template: (data) =>
		
		tmpl = """
			<td>
				#{@tag()}
			</td>
			<td><%= obj.get('tags').join(', ') %></td>
			<td><%= obj.get('mtime').toLocaleString() %></td>
			<td><%= obj.get('contentType') %></td>
			<td><%= obj.get('size') %></td>
		"""
		_.template tmpl, @model

	events:			
		'click':		'toggleSelect'
		'click a':		'open'
		
	modelEvents:
		'change':				'render'

	onRender: ->
		@$el.toggleClass 'selected', @model.get('selected')
		
	toggleSelect: (event) ->
		@model.toggleSelect()
		
	open: (event) ->
		event.stopPropagation()
		if @model.isDir()
			@model.collection.cd @model.get('path')
		return not @model.isDir()
		
class FileIconView extends FileView
	tagName:	'span'
	
	template: (data) =>
		@tag()

class FileListView extends Marionette.ItemView
	listTemplate: (data) =>
		"""
			<table>
				<thead>
					<tr>
						<th class='name'>Name</th>
						<th class='tags'>Tags</th>
						<th class='lastUpdated'>Last Updated</th>
						<th class='type'>Type</th>
						<th class='size'>Size</th>
					</tr>
				</thead>
			</table>
		"""
			
	template: (data) =>
		tmpl = """
			<ul class="file-pager pager">
				<li class="previous <%=obj.collection.hasPreviousPage() ? '' : 'disabled'%>">
					<a href="#">&laquo; prev</a>
				</li>
				<li class="next <%=obj.collection.hasNextPage() ? '' : 'disabled'%>">
					<a href="#">next &raquo;</a>
				</li>
			</ul>
		"""
		return @listTemplate(data) + _.template tmpl, @
		
	events:
		'click .file-pager li.previous':	'prev'
		'click .file-pager li.next':		'next'
		
	collectionEvents:
		'sync':		'render'
		
	constructor: (opts) ->
		super(opts)
		@view = new Marionette.CollectionView {tagName: 'tbody', className: 'file-list', collection: opts.collection, itemView: FileView}
			
	onRender: =>
		@$('table').append @view.render().el 
		
	prev: (event) ->
		event.preventDefault()
		if @collection.hasPreviousPage()
			@collection.getPreviousPage()
		
	next: (event) ->
		event.preventDefault()
		if @collection.hasNextPage()
			@collection.getNextPage()
		
class FileIconListView extends FileListView
	listTemplate: (data) =>
		""
		
	constructor: (opts) ->
		super(opts)
		@view = new Marionette.CollectionView {tagName: 'div', className: 'file-list', collection: opts.collection, itemView: FileIconView}
		
	onRender: ->
		@$el.prepend @view.render().el
		
###
model:		File instance of current directory
collection:	Files instance for collection of files
###	
class FileSearchView extends Marionette.Layout
	template: (data) =>
		tmpl = """
			<div id='content'>
				<div id='navbar' />
				<div id='file' />
			</div>
		""" 
		
	regions:
		navbar:		'#navbar'
		file:		'#file'
		
	events:
		'click .contextMenu .rename':		'rename'
		'click .contextMenu .remove':		'remove'
		
	constructor: (opts) ->
		super(opts)
		@users = new scope.model.Users()
		@views = 
			navbar: new NavBar(collection: @collection)
			file:	new FileListView(collection: @collection)
			alluser:	new userController.UserSearchView(collection: @users)
			
		vent.on 'show:msg', (msg, type='other') =>
			flash = new lib.FlashView {model: new Backbone.Model({type: type, msg: msg})}
			flash.render().$el.insertAfter('nav')
		vent.on 'icon:file', =>
			@views.file = new FileIconListView(collection: @collection)
			@file.show @views.file
		vent.on 'list:file', =>
			@views.file = new FileListView(collection: @collection)
			@file.show @views.file
		vent.on 'list:user', =>
			@users.fetch()
			@views.alluser = new userController.UserSearchView(collection: @users)
			@file.show @views.alluser
			
	onRender: ->
		@navbar.show @views.navbar
		@file.show @views.file
		lib.ModalView.getInstance().$el.insertAfter('nav')

module.exports =	
	FileSearchView: FileSearchView