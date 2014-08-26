env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'
fs = require 'fs'

error = (res, msg) ->
	res.json 501, error: msg.err

class File
	@_list: (req, res) ->
		path = req.params[0].replace /\/$/, ''			# remove trailing slash
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		cond = { dir: path }
		# search is not empty or null
		if !! req.query.search 
			pattern = new RegExp(req.query.search, 'i')
			fields = _.map model.File.search_fields(), (field) ->
				ret = {}
				ret[field] = pattern
				return ret
			# tags contains input search criteria
			fields.push tags: req.query.search
			# file under the input path and file name match input search criteria
			cond = $and: [
				dir:	new RegExp('^' + path)
				$or:	fields
			]
		
		order_by = lib.order_by model.File.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.File.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.File.find(cond, null, opts).populate('createdBy updatedBy').sort(order_by).exec (err, files) ->
			if err
				return error res, err
			model.File.count cond, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: files}
			
	@_read: (req, res) ->
		path = req.params[0]
		model.File.findOne(path: path).populate('createdBy updatedBy').exec (err, file) ->
			if err or file == null
				return error res, if err then err else "File not found"
			path = "#{env.file.uploadDir}/#{file.path}"
			res.download path 
	
	@open: (req, res) ->
		res.sendfile model.FileUtil.abspath(req.params[0])
		
	@create: (req, res) ->
		path = req.body.path
		contentType = req.body.contentType
		if _.isUndefined contentType
			contentType = 'text/plain'
		file = new model.File {path: path, contentType: contentType, createdBy: req.user}
		file.stream = req.body.file
		file.save (err) =>
			if err
				return error res, err
			res.json file			
			
	@read: (req, res) ->
		path = model.FileUtil.abspath req.params[0]
		if fs.existsSync path
			stat = fs.statSync path  
			func = if stat.isDirectory() then File._list else File._read
			func req, res
		else
			error res, err: "#{req.params[0]} does not exist"
			
	@update: (req, res) ->
		path = req.params[0]
		model.File.findOne {path: path, __v: req.body.__v}, (err, file) ->
			if err or file == null
				return error res, if err then err else "File not found"
			
			if req.body.file?
				file.stream = req.body.file
			_.extend file, _.pick(req.body, 'path', 'contentType')
			if not _.isUndefined(req.body.name)
				file.rename req.body.name
			if !! req.body.tags
				file.tags = req.body.tags.split(',')
			file.updatedBy = req.user
			file.save (err) ->
				if err
					return error res, err
				res.json file				
					
	@delete: (req, res) ->
		path = req.params[0]
		model.File.findOne {path: path}, (err, file) ->		
			if err or file == null
				return error res, if err then err else "File not found"
			
			file.remove (err, file) ->
				if err
					return error res, err
				res.json {deleted: true}
					
module.exports = 
	File: 		File