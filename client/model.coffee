env = require './env.coffee'
_ = require 'underscore'
Backbone = require 'backbone'
require 'backbone.paginator'
Promise = require '../promise.coffee'
path = require 'path'
vent = require './vent.coffee'

class Model extends Backbone.Model
	idAttribute:	'_id'
	
	# input fields
	fields: ->
		_.keys @schema
		
	# fields to be displayed
	showFields: ->
		_.keys @schema
		
class PageableCollection extends Backbone.PageableCollection
	pattern:	''
	
	state:
		pageSize:	10
		
	queryParams:
		sortKey:	'order_by'
		
	parseState: (resp, queryParams, state, options) ->
		ret = _.clone(state)
		ret.totalRecords = resp.count
		ret.lastPage = Math.ceil(resp.count / ret.pageSize)
		ret.totalPages = ret.lastPage
		return ret
		
	parseRecords: (res) ->
		return res.results
		
	search: (name) ->
		@pattern = name
		@getFirstPage reset: true
		
	fetch: (opts = {}) ->
		opts.data = search: @pattern
		super(opts)
		
class User extends Model
	urlRoot:	"#{env.path}/api/user"
	
	schema:
		url:			{ type: 'Text', title: 'URL'}
		username:		{ type: 'Text', title: 'Username' }
		email:			{ type: 'Text', title: 'Email' }
		tags:
			type: 		'List'
			itemType: 	'NestedModel'
			model: 		String
			title: 		'Tags'
			
	@fields:	
		show:	[ 'username' ]
	
	showFields: ->
		_.keys _.pick(@schema, 'username')
		
	toString: ->
		@get 'username'
		
	homeDir: ->
		"#{@get('username')}/" 
		
class Users extends PageableCollection
	url:		"#{env.path}/api/user"
	
	comparator:	'username'
	
	model:	User
	
	schema:
		models:	{type: 'List', itemType: 'NestedModel', model: User }
			
class AllUsers extends Backbone.Collection
	url:		"#{env.path}/api/user/all"
	
	comparator:	'username'
	
	model:	User
	
	schema:
		models:	{type: 'List', itemType: 'NestedModel', model: User }
	
class OGCIOUsers extends Users
	url:		env.user.url
		
	@me: ->
		user = new User()
		p = user.fetch url: env.user.url + 'me/'
		p.then ->
			return user		

class Permission extends Model
	toString: ->
		"#{@get('userGrp')}:#{@get('fileGrp')}:#{@get('action')}"

class Permissions extends PageableCollection
	url:		"#{env.path}/api/permission"
	
	model:		Permission
	
	mode:		'infinite'

class File extends Model
	idAttribute:	'path'
	
	schema:
		path:	{type: 'Text', validators: ['required']}
	
	constructor: (attrs = {}, opts = {}) ->
		attrs.selected = attrs.selected ? false
		super(attrs, opts)
		
	parse: (res, opts) ->
		res.atime = new Date(Date.parse(res.atime))
		res.ctime = new Date(Date.parse(res.ctime))
		res.mtime = new Date(Date.parse(res.mtime))
		return res
	
	accessUrl: ->
		path.join(env.path, @get('path'))
		
	iconUrl: ->
		ret = env.icons[@get('contentType')]
		ret ?= path.join(env.path, "img", "unknown.png") 
		return ret		
				
	dirname: ->
		path.dirname @get('path')
		
	basename: ->
		path.basename @get('path')
		
	extname: ->
		path.extname @get('path')
	
	isNew: ->
		_.isUndefined @get('_id')
		
	isFile: ->
		not @isDir
	
	isDir: ->
		/\/$/.test @get('path')
		
	toggleSelect: ->
		@set('selected', not @get('selected'))
		
	select: ->
		@set('selected', true)
		
	deselect: ->
		@set('selected', false)
		
	rename: (newname) ->
		@set 'name', newname
		
	hasTag: (tag) ->
		_.contains(@get('tags'), tag)
			
	addTag: (tag) ->
		if not @hasTag(tag)
			@get('tags').push(tag)
		return @
	
	removeTag: (tag) ->
		if @hasTag(tag)
			@set 'tags', _.difference @get('tags'), tag
		return @
			
	toString: ->
		@basename()
		
	sync: (method, model, opts) ->
		switch method
			when 'create', 'update'
				formData = new FormData()
				_.each model.attributes, (value, key) ->
					formData.append key, value
				_.defaults opts, { data: formData, processData: false, contentType: false }
				Backbone.sync method, model, opts
			when 'delete'
				Backbone.sync method, model, opts
			when 'read'
				xhr = new XMLHttpRequest()
				xhr.open('GET', @url(), true)
				xhr.setRequestHeader "Authorization", "Bearer #{jso_getToken('oauth2')}"
				xhr.responseType = 'blob'
				xhr.onload = (e) ->
					if @status = 200
						saveAs @response, model.get('name')
				xhr.send()
						
class Files extends PageableCollection
	url:	"#{env.path}/api/file/"
	
	comparator:	'path'
	
	model:		File
	
	selectAll: ->
		@each (file) ->
			file.select()
			
	deselectAll: ->
		@each (file) ->
			file.deselect()
		
	selected: ->
		@where selected: true
		
	refresh: ->
		@getFirstPage(reset: true)
	
class Dir extends Files
	constructor: (models = [], opts = {}) ->
		@path = opts.path
		super(models, opts)
		@refresh()
		
	cwd: ->
		@path
		
	home: ->
		OGCIOUsers.me().then (me) =>
			@cd me.homeDir()
			
	up: ->
		parent = path.dirname(@path)
		if parent == '.'
			return
		@cd parent
		
	cd: (path) ->
		if path == @path
			return
		@path = path
		@refresh()
		
	sync: (method, model, opts) ->
		if method == 'read'
			opts.url = "#{@url}#{@path}"
		super(method, model, opts)

class FileGrp extends Backbone.Model
	idAttribute:	'tag'
	
	toString: ->
		@get('tag')
		
class FileGrps extends Backbone.Collection
	url:	"#{env.path}/api/tag"
	
	model:	FileGrp
	
class UserGrp extends Backbone.Model
	idAttribute:	'tag'
	
	toString: ->
		@get('tag')
		
im = require 'restim/client/model.coffee'

class UserGrps extends Backbone.Collection
	model:	UserGrp
	
	roster: new im.Roster()
	
	fetch: (opts = {}) ->
		return new Promise (fulfill, reject) =>
			success = =>
				keys = _.keys @roster.groups()
				keys = _.map keys, (tag) ->
					tag: tag
				@set keys, opts
				fulfill(arguments)
			@roster.fetch(opts).then success, reject

module.exports =
	Permission:		Permission
	Permissions:	Permissions
	User:			User
	Users:			Users
	OGCIOUsers:		OGCIOUsers
	File:			File
	Files:			Files
	Dir:			Dir
	FileGrps:		FileGrps
	UserGrps:		UserGrps