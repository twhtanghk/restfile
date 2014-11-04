model = require '../../../model.coffee'
Promise = require '../../../promise.coffee'

class Permission
	@list: (condition, pagination, order) ->
		return new Promise (fulfill, reject) ->
			p = new Promise.all [
				model.Permission.find(condition, null, pagination).sort(order).exec(),
				model.Permission.count(condition).exec()
			]
			success = (res) ->
				fulfill {count: res[1], results: res[0]}
			p.then success, reject
		
	@create: (user, data) ->
		return new Promise (fulfill, reject) ->
			perm = new model.Permission data
			perm.save (err, perm) ->
				if err
					reject err
				else
					fulfill perm.toJSON()
					
	@delete: (user, id) ->
		return new Promise (fulfill, reject) ->
			model.Permission.findById id, (err, perm) ->		
				if err or perm == null
					reject if err then err else "Permission not found"
				
				perm.remove (err) ->
					if err
						reject(err)
					else
						fulfill("deleted successfully")
			
module.exports = 
	Permission: 	Permission