path = require 'path'
env = require '../../env.coffee'
model = require '../../model.coffee'

logger = env.log4js.getLogger('permission')

field = (name) ->
	if name.charAt(0) == '-'
		return name.substring(1)
	return name
	
order = (name) ->
	if name.charAt(0) == '-'
		return -1
	return 1
	
order_by = (name) ->
	ret = {}
	ret[field(name)] = order(name)
	return ret
		
newHome = ->
	(req, res, next) ->
		model.File.findOrCreate {path: "#{req.user.username}/", createdBy: req.user}, (err, file) ->
			if err
				res.json 501, error: err
			else next()
		
###
user: 		req.user
p:			domain:action
file:		create: req.body.path or other: req.params[0]	
###
ensurePermission = (p) ->
	(req, res, next) ->
		user = req.user
		home = new RegExp "^#{user.username}"
		filepath = req.params[0]
		
		# if user list, read allow
		if p == 'user:list' or p == 'user:read'
			return next()
		
		# if file/dir creation, check parent folder ownership and permission
		if p == 'file:create'
			filepath = path.dirname(req.body.path)
			
		model.File.findOne {path: {$in: [filepath, "#{filepath}/"]}}, (err, file) ->
			if err or file == null
				return res.json 501, error: err
			if file.createdBy.id == user._id.id
				return next()
			perm = [p, file.path.replace(home, '%home')].join(':')
			req.user?.checkPermission(perm).then (permitted) ->
				logger.debug "#{user.username} #{perm}: #{permitted}"
				if permitted
					return next()
				else res.json 401, error: 'Unauthorzied access'

module.exports =
	field:				field
	order:				order
	order_by:			order_by
	newHome:			newHome
	ensurePermission:	ensurePermission