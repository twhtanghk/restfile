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
		
model = (ActiveRecord, $q) ->

	User = ActiveRecord.extend
		$urlRoot: "#{env.authUrl}/org/api/users/"
		
	User.me = ->
		user = new User(id: 'me/')
		p = user.$fetch()
		fulfill = (user) ->
			return user
		reject = (err) ->
			alert err
		p.then fulfill, reject
			
	File = ActiveRecord.extend
		$urlRoot: "#{env.serverUrl()}/file/api/file"
		
		$idAttribute: 'path'
		
		$parse: (res, opts) ->
			res.atime = new Date(Date.parse(res.atime))
			res.ctime = new Date(Date.parse(res.ctime))
			res.mtime = new Date(Date.parse(res.mtime))
			res.iconUrl = iconUrl(res.contentType) 
			res.url = if env.isMobile() then "#{env.serverUrl()}/file/api/file/content/#{res.path}" else "#{env.serverUrl()}/file/#{res.path}" 
			return res
	
	###
	opts:
		path:		path of folder to be fetched
		params:
			page:		page no to be fetched (first page = 1)
			per_page:	no of records per page
	###
	File.fetchPage = (opts) ->
		opts.params.page ?= 1
		opts.params.per_page ?= 10
		model = new File(path: opts.path, opts)
		deferred = $q.defer()
		fulfill = (response) ->
			for file in response.data.results
				file = new File(file, parse: true)
			deferred.resolve angular.extend response.data,
				state:
					count:		response.data.count
					page:		opts.params.page
					per_page:	opts.params.per_page
					total_page:	Math.ceil(response.data.count / opts.params.per_page)
		model.$sync('read', model, opts).then fulfill, deferred.reject
		return deferred.promise
		
	User:	User
	File:	File
			
config = ->
	return
	
angular.module('starter.model', ['ionic', 'ActiveRecord']).config [config]

angular.module('starter.model').factory 'model', ['ActiveRecord', '$q', model]