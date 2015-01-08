clientEnv = require './client/env'
env = require './env'
logger = env.log4js.getLogger('app.coffee')
path = require 'path'
model = require './model'
i18n = require 'i18n'
passport = require 'passport'
bearer = require 'passport-http-bearer'
http = require 'needle'
_ = require 'underscore'
fs = require 'fs'
busboy = require 'connect-busboy'
bodyParser = require 'body-parser'
middleware = require './middleware.coffee'

i18n.configure
	locales:		['en', 'zh', 'zh-tw']
	directory:		__dirname + '/locales'
	defaultlocale:	'en'

port = process.env.PORT || 3000

require('zappajs') port, ->
	@set 'view engine': 'jade'
	# strip url with prefix = env.app.path 
	@use (req, res, next) ->
		p = new RegExp('^' + env.app.path)
		req.url = req.url.replace(p, '')
		next()
	@use 'logger', 'cookieParser', session:{secret:'keyboard cat'}, 'methodOverride'
	@use bodyParser.json()
	@use busboy(immediate: true)
	@use (req, res, next) ->
		req.body ?= {}
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
	@use middleware.nocache
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
		@response.redirect env.app.path
		
	@get '/', ->
		@render 'index.jade', {path: env.app.path, title: 'TTFile'}
	
	@include './server/mongoose/url/user.coffee'
	@include './server/mongoose/url/role.coffee'
	@include './server/mongoose/url/permission.coffee'
	@include './server/mongoose/url/file.coffee'