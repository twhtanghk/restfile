model = (ActiveRecord, $q) ->

	User = ActiveRecord.extend
		$urlRoot: 'https://mob.myvnc.com/org/api/users/'
		
	User.me = ->
		user = new User(id: 'me/')
		p = user.$fetch()
		fulfill = (user) ->
			return user
		reject = (err) ->
			alert err
		p.then fulfill, reject
			
	File = ActiveRecord.extend
		$urlRoot: 'https://mob.myvnc.com/file/api/file'
		
		$idAttribute: 'path'
		
		$parse: (res, opts) ->
			res.atime = new Date(Date.parse(res.atime))
			res.ctime = new Date(Date.parse(res.ctime))
			res.mtime = new Date(Date.parse(res.mtime))
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