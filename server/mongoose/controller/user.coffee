env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'

error = (res, msg) ->
	res.json 500, error: msg

class User

	@list: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		cond = {}
		if req.query.search 
			pattern = new RegExp(req.query.search, 'i')
			fields = _.map model.User.search_fields(), (field) ->
				ret = {}
				ret[field] = pattern
				return ret
			cond = $or: fields 
		
		order_by = lib.order_by model.User.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.User.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.User.find(cond, null, opts).populate('createdBy updatedBy').sort(order_by).exec (err, users) ->
			if err
				return error res, err
			model.User.count cond, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: users}
			
	@read: (req, res) ->
		id = req.param('id')
		model.User.findById(id).populate('createdBy updatedBy').exec (err, user) ->
			if err or user == null
				return error res, if err then err else "User not found"
			res.json user			
					
module.exports = 
	User: 		User