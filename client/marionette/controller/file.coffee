env = require '../../env.coffee'
Promise = require '../../../promise.coffee'
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

class DirInput extends Marionette.LayoutView
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
	
class SearchInput extends Marionette.LayoutView
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
		@collection.search(@$('input#search').val()).then false, vent.error
				
class NavMenu extends Marionette.LayoutView
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
			
class NavBar extends Marionette.LayoutView
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
		'click a':							'hide'
		'change input#cwd':					'hide'
		'click .glyphicon-circle-arrow-up':	'hide'
		'click .glyphicon-refresh':			'hide'
		'click .glyphicon-search':			'hide'
		'submit form':						'hide'				
		'click a#home':						'home'
		'click a#newfile':					'newfile'
		'click a#newdir':					'newdir'
		'click a#edit':						'edit'
		'click a#addTags':					'addTags'
		'click a#removeTags':				'removeTags'
		'change input.file-upload':			'upload'
		'click a#download':					'download'
		'click a#selectAll':				'selectAll'
		'click a#deselectAll':				'deselectAll'
		'click a#icon':						'icon'
		'click a#list':						'list'
		'click a#trash':					'trash'
		'click a#share':					'share'
		
	constructor: (opts) ->
		home = new Backbone.Model
			id:				'home'
			prependIcon:	'home'
			title:			'home'
			href:			'#file'
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
			href:			'#file/icon'
		list = new Backbone.Model
			id:				'list'
			prependIcon: 	'th-list'
			title: 			'list'
			href:			'#file/list'
		trash = new Backbone.Model
			id:				'trash'
			prependIcon: 	'trash'
			title: 			'delete'
		share = new Backbone.Model
			id:				'share'
			prependIcon:	'share'
			title:			'share'
			href:			'#file/auth'
		
		btns = [home, newdir, addTags, removeTags, edit, upload, download, selectAll, deselectAll, icon, list, trash, share]
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
		@$el.append lib.ModalView.getInstance().$el
		
	# hide navbar if navbar-toggle is displayed in small screen factor
	hide: ->
		if $('.navbar-toggle').css('display') !='none'
			$('.navbar-collapse').toggleClass('in', false)
	
	home: (event) ->
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
		
class FileView extends Marionette.ItemView
	tagName:	'div'
	
	className:	'file'
	
	tag: ->
		tmpl = """
			<img src='#{@model.iconUrl()}' alt='<%= obj.basename() %>'>
			<a href="<%= obj.accessUrl() %>" target='_blank'><%= obj.toString() %></a>
		"""
		_.template tmpl, @model
		
	template: (data) =>
		_.template """
			#{@tag()}
			<span class='tags'>
				<%= obj.get('tags').join(', ') %>
			</span>
			<span class='lastUpdated'>
				<%= obj.get('mtime').toLocaleString() %>
			</span>
			<span class='type'>
				<%= obj.get('contentType') %>
			</span>
			<span class='size'>
				<%= obj.get('size') %>
			</span>
		""", @model

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
	
	className:	'icon'
	
	template: (data) =>
		@tag()

class FileListView extends Marionette.CompositeView
	childView:				FileView
	
	childViewContainer:		'div.file-list'
	
	template: (data) =>
		_.template """
			<div class='file-list'>
			</div>
			<ul class="file-pager pager">
				<li class="previous <%=obj.hasPreviousPage() ? '' : 'disabled'%>">
					<a href="#">&laquo; prev</a>
				</li>
				<li class="next <%=obj.hasNextPage() ? '' : 'disabled'%>">
					<a href="#">next &raquo;</a>
				</li>
			</ul>
		""", @collection
		
	events:
		'click .file-pager li.previous':	'prev'
		'click .file-pager li.next':		'next'
		
	prev: (event) ->
		event.preventDefault()
		if @collection.hasPreviousPage()
			@collection.getPreviousPage()
		
	next: (event) ->
		event.preventDefault()
		if @collection.hasNextPage()
			@collection.getNextPage()
		
class FileIconListView extends FileListView
	childView:				FileIconView
		
class AuthView extends Marionette.ItemView
	className:	'authlist'
	
	template: (data) ->
		"""
			<div class='field-userGrp'>
				#{data.userGrp}
			</div>
			<div class='field-fileGrp'>
				#{data.fileGrp}
			</div>
			<div class='field-action'>
				#{data.action?.join(', ')}
			</div>
			<div class='field-button'>
				<a class='btn btn-default delete' href='#'>Delete</a>
			</div>
		"""
		
	events:
		'click .delete':	'delete'
		
	'delete': (event) ->
		event.preventDefault()
		fulfill = ->
			vent.trigger 'show:msg', 'deleted successfully'
		@model.destroy().then fulfill, vent.error
		
class AuthCreateView extends Marionette.ItemView
	className:	'authlist'
	
	template: (data) =>
		@form = new Backbone.Form
			schema:
				userGrp:	
					type: 		'Select'
					options:	@userGrp
				fileGrp:	
					type: 		'Select'
					options:	@fileGrp
				action:
					type: 		'MSelect'
					options: 	[
						{ label: 'read', val: 'read' }
						{ label: 'write', val: 'write' }
					]
				button:
					template: (data) ->
						_.template """
							<div class="form-group field-<%= key %>">
								<button type='submit' class='btn btn-default'>Add</button>
							</div>
						""", data
			Field: 		Backbone.Form.FieldOnly
			template:	->
				"""
	    			<form class="form-inline" role="form">
	    				<div data-fieldsets></div>
	    			</form>
  				"""
		@form.render().el
  		
	events:
		'submit':	'add'
		
	constructor: (opts = {}) ->
		super(opts)
		@userGrp = new scope.model.UserGrps()
		@fileGrp = new scope.model.FileGrps()
		
	add: (event) ->
		event.preventDefault()
		model = new scope.model.Permission(@form.getValue(), collection: @collection)
		fulfill = =>
			@collection.add model
			vent.trigger 'show:msg', 'saved successfully'
		model.save().then fulfill, vent.error
	
class AuthListView extends Marionette.LayoutView
	template: (data) ->
		"""
			<div class='create'></div>
			<div class='list'></div>
		"""
	
	regions:
		create:		'.create'
		list:		'.list'		
		
	onRender: ->
		@create.show new AuthCreateView collection: @collection
		@list.show new Marionette.CollectionView childView: AuthView, collection: @collection
	
module.exports =	
	NavBar:				NavBar
	FileListView: 		FileListView
	FileIconListView:	FileIconListView
	AuthView:			AuthView
	AuthListView:		AuthListView