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
		
	handler: (user, response) ->
		reject: (err) ->
			response.json 501, err
		fulfill: (res) ->
			response.json res
		
module.exports = 
	rest:	rest