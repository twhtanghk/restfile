env = require './env.coffee'

window.Promise = require 'promise'
window._ = require 'underscore'
window.$ = require 'jquery'
window.$.deparam = require 'jquery-deparam'
if env.isMobile()
	window.$.getScript 'cordova.js'
	
require 'ngCordova'
require 'angular-activerecord'
require 'angular-http-auth'
require 'tagDirective'
require './app.coffee'
require './controller.coffee'
require './model.coffee'
require './platform.coffee'