envClient = require './client/env.coffee'
env = require './env.coffee'
logger = env.log4js.getLogger('middleware.coffee')
passport = require 'passport'
bearer = require 'passport-http-bearer'
Promise = require './promise.coffee'
fs = require 'fs'
http = require 'needle'
_ = require 'underscore'
model = require './model'

dir = '/etc/ssl/certs'
files = fs.readdirSync(dir).filter (file) -> /.*\.pem/i.test(file)
files = files.map (file) -> "#{dir}/#{file}"
ca = files.map (file) -> fs.readFileSync file

passport.serializeUser (user, done) ->
	done(null, user.id)
	
passport.deserializeUser (id, done) ->
	model.User.findById id, (err, user) ->
		done(err, user)

verifyToken = (token) ->
	opts = 
		timeout:	envClient.promise.timeout
		ca:			ca
		headers:
			Authorization:	"Bearer #{token}"
	
	return new Promise (fulfill, reject) ->
		http.get env.oauth2.verifyURL, opts, (err, res, body) ->
			if err or res.statusCode != 200
				return reject('Unauthorized access')
					
			# check required scope authorized or not
			scope = body.scope.split(' ')
			result = _.intersection scope, envClient.oauth2.scope
			if result.length != envClient.oauth2.scope.length
				return reject('Unauthorized access to #{envClient.oauth2.scope}')
				
			# create user
			# otherwise check if user registered before (defined in model.User or not)
			user = _.pick body.user, 'url', 'username', 'email'
			model.User.findOrCreate user, (err, user) ->
				if err
					return reject(err)
				fulfill(user)

passport.use 'bearer', new bearer.Strategy {}, (token, done) ->
	fulfill = (user) ->
		user.token = token
		done(null, user)
	reject = (err) ->
		done(err, null)
	verifyToken(token).then fulfill, reject
	
passport.use 'provider', new env.oauth2.provider.Strategy env.oauth2, (token, refreshToken, profile, done) ->
	model.User.findOne(url: profile.id).exec (err, user) ->
		if err
			return done(err, null)
		done(err, user)
	
rest = 
	user: (req, res, next) ->
		auth = passport.authenticate('bearer', { session: false })
		auth(req, res, next)
		
	handler: (response) ->
		reject: (err) ->
			response.json 501, err
		fulfill: (res) ->
			response.json res
			
# check if current login user and each of the input groups (:group) is element of (:owner).roster.(user).groups
isElement = (owner, userGrps, user) ->
	return new Promise (fulfill, reject) ->
		url = _.template env.xmpp.url, owner: owner
		opts = 
			timeout:	envClient.promise.timeout
			ca:			ca
			headers:
				Authorization:	"Bearer #{user.token}"
		data = _.map userGrps, (group) ->
			"groups=#{group}"
		http = require 'needle'
		http.get "#{url}?#{data.join('&')}", opts, (err, res) ->
			if err
				reject err
			else
				fulfill res.body 

###
user: 		req.user
p:			domain:action
file:		create: req.body.path or other: req.params[0]	
###
ensurePermission = (p) ->
	(req, res, next) ->
		user = req.user
		name = req.params[0] || req.body.path
		if not fs.existsSync model.FileUtil.abspath name
			path = require 'path'
			name = path.dirname name
			
		reject = (err) ->
			res.json 401, err
		
		fulfill = (file) ->
			if file.createdBy.id == user.id
				return next()
			success = (perms) ->
				if perms.length == 0
					return reject("no permission defined")
				userGrps = _.map perms, (perm) ->
					perm.userGrp
				isElement(file.createdBy.username, userGrps, user).then (result) ->
					if _.some(_.values(result))
						next()
					else
						reject(result)		
			model.Permission.find(fileGrp: {$in: file.tags}, action: p, createdBy: file.createdBy).exec().then success, reject
			
		model.File.findOne({path: {$in: [name, "#{name}/"]}}).populate('createdBy').exec().then fulfill, reject 
		
module.exports = 
	rest:				rest
	ensurePermission:	ensurePermission