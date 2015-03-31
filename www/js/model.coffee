env = require './env.coffee'

iconUrl = (type) ->
	icon = 
		"text/directory":				"img/dir.png"
		"text/plain":					"img/txt.png"
		"text/html":					"img/html.png"
		"application/javascript":		"img/js.png"
		"application/octet-stream":		"img/dat.png"
		"application/pdf":				"img/pdf.png"
		"application/excel":			"img/xls.png"
		"application/x-zip-compressed":	"img/zip.png"
		"application/msword":			"img/doc.png"
		"image/png":					"img/png.png"
		"image/jpeg":					"img/jpg.png"
	return if type of icon then icon[type] else "img/unknown.png"
		
model = (ActiveRecord, $rootScope, $upload, platform) ->
	
	class User extends ActiveRecord
		$idAttribute: 'username'
		
		$urlRoot: "#{env.authUrl}/org/api/users/"
		
		constructor: (attrs = {}, opts = {}) ->
			@$initialize attrs, opts
			
		@me: ->
			(new User(username: 'me/')).$fetch()	
			
	class File extends ActiveRecord
		$idAttribute: 'path'
	
		$urlRoot: "#{env.serverUrl()}/file/api/file/"
		
		constructor: (attrs = {}, opts = {}) ->
			@$initialize attrs, opts
			@models = []
			@length = @models.length
			@state =
				count:		0
				page:		0
				per_page:	10
				total_page:	0
			
		$parseModel: (res, opts) ->
			res.selected = false
			res.atime = new Date(Date.parse(res.atime))
			res.ctime = new Date(Date.parse(res.ctime))
			res.mtime = new Date(Date.parse(res.mtime))
			res.iconUrl = iconUrl(res.contentType) 
			res.url = if env.isMobile() then "#{env.serverUrl()}/file/api/file/content/#{res.path}" else "#{env.serverUrl()}/file/#{res.path}"
			return res
			
		$parseCollection: (res, opts) ->
			_.each res.results, (value, key) =>
				res.results[key] = new File(@$parseModel(value))
			return res
			
		$parse: (res, opts) ->
			if res.count?
				@$parseCollection(res, opts)
			else
				@$parseModel(res, opts)
				
		###
		opts:
			params:
				page:		page no to be fetched (first page = 1)
				per_page:	no of records per page
		###
		$fetch: (opts = {}) ->
			opts.params = opts.params || {}
			opts.params.page = @state.page + 1
			opts.params.per_page = opts.params.per_page || @state.per_page
			return new Promise (fulfill, reject) =>
				super(opts)
					.then (res) =>
						@add res.results
						@state = _.extend @state,
							count:		res.count
							page:		opts.params.page
							per_page:	opts.params.per_page
							total_page:	Math.ceil(res.count / opts.params.per_page)
						fulfill @
					.catch reject
				
		$isNew: ->
			not @_id?
			
		toggleSelect: ->
			@selected = not @selected
			$rootScope.$broadcast 'mode:select'	
		
		open: ->
			platform.open @
			
		add: (models, opts = {}) ->
			singular = not _.isArray(models)
			if singular and models?
				models = [models]
			_.each models, (file) =>
				if not @contains file 
					@models.push file
					@length++
				
		remove: (models, opts = {}) ->
			singular = not _.isArray(models)
			if singular and models?
				models = [models]
			_.each models, (model) =>
				@models = _.filter @models, (file) =>
					file[@$idAttribute] != model[@$idAttribute]
			@length = @models.length
				
		contains: (model) ->
			ret = _.find @models, (file) =>
				file[@$idAttribute] == model[@$idAttribute] 
			return ret?				
			 
		nselected: ->
			(_.where @models, selected: true).length
			
		$sync: (op, model, opts) ->
			if op in ['create', 'update']
				crudMapping =
					create:		'POST'
					read:		'GET'
					update:		'PUT'
					"delete":	'DELETE'
				$upload.upload
					url:	if op == 'create' then @$urlRoot else @$url()
					method:	crudMapping[op]
					fields:	_.pick model, 'name', 'path', 'tags', '__v'
					file:	model.file
			else
				super(op, model, opts)
				
	User:		User
	File:		File
			
config = ->
	return
	
angular.module('starter.model', ['ionic', 'ActiveRecord', 'angularFileUpload']).config [config]

angular.module('starter.model').factory 'model', ['ActiveRecord', '$rootScope', '$upload', 'platform', model]