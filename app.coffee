clientEnv = require './client/env'
env = require './env'
logger = env.log4js.getLogger('app.coffee')
path = require 'path'
require './bootstrap'
model = require './model'
i18n = require 'i18n'
passport = require 'passport'
bearer = require 'passport-http-bearer'
http = require 'needle'
_ = require 'underscore'
fs = require 'fs'
busboy = require 'connect-busboy'
ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

dir = 'D:/etc/ssl/certs'
files = fs.readdirSync(dir).filter (file) -> /.*\.pem/i.test(file)
files = files.map (file) -> "#{dir}/#{file}"
ca = files.map (file) -> fs.readFileSync file

i18n.configure
	locales:		['en', 'zh', 'zh-tw']
	directory:		__dirname + '/locales'
	defaultlocale:	'en'

passport.serializeUser (user, done) ->
	done(null, user.id)
	
passport.deserializeUser (id, done) ->
	model.User.findById id, (err, user) ->
		done(err, user)

passport.use 'bearer', new bearer.Strategy {}, (token, done) ->
	opts = 
		ca:		ca
		headers:
			Authorization:	"Bearer #{token}"
	http.get env.oauth2.verifyURL, opts, (err, res, body) ->
		if err?
			logger.error err
				
		client_id = body.client_id
		
		# check required scope authorized or not
		scope = body.scope.split(' ')
		result = _.intersection scope, clientEnv.oauth2.scope
		if result.length != clientEnv.oauth2.scope.length
			return done('Unauthorzied access', null)
			
		# create user
		# otherwise check if user registered before (defined in model.User or not)
		user = _.pick body.user, 'url', 'username', 'email'
		model.User.findOrCreate user, (err, user) ->
			if err
				return done(err, null)
			done(err, user)
			
passport.use 'provider', new env.oauth2.provider.Strategy env.oauth2, (token, refreshToken, profile, done) ->
	model.User.findOne(url: profile.id).exec (err, user) ->
		if err
			return done(err, null)
		done(err, user)

port = process.env.PORT || 3000

require('zappajs') port, ->
	@set 'view engine': 'jade'
	@set 'views': __dirname + '/views'
	
	# strip url with prefix = env.path 
	@use (req, res, next) ->
		p = new RegExp('^' + env.path)
		req.url = req.url.replace(p, '')
		next()
	@use 'logger', 'cookieParser', session:{secret:'keyboard cat'}, 'methodOverride'
	@use busboy(immediate: true)
	@use (req, res, next) ->
		req.body = {}
		req.busboy?.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			_.extend req.body, filename: filename, file: file, contentType: mimetype
		req.busboy?.on 'field', (key, value, keyTruncated, valueTruncated) ->
			req.body[key] = value
		next()
	@use passport.initialize()
	@use passport.session()
	@use static: __dirname + '/public'
	@use 'zappa'
	@use i18n.init
	# locales
	@use (req, res, next) ->
		if req.locale == 'zh' and req.region == 'tw'
			res.locals.setLocale 'zh-tw'
		next()
	
	@get env.oauth2.authURL, passport.authenticate('provider', scope: env.oauth2.scope)
	
	@get env.oauth2.cbURL, passport.authenticate('provider', scope: env.oauth2.scope), ->
		@response.redirect @session.returnTo
		
	@get '/auth/logout', ->
		@request.logout()
		@response.redirect('/')
		
	@get '/', ->
		@render 'index.jade', {path: env.path, title: 'TTFile'}
	
	@include './server/mongoose/url/user.coffee'		# user api
	@include './server/mongoose/url/role.coffee'		# role api
	@include './server/mongoose/url/file.coffee'		# file api