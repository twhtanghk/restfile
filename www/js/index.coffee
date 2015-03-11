env = require './env.coffee'

window.Promise = require 'promise'
window._ = require 'underscore'
window.$ = require 'jquery'
window.$.deparam = require 'jquery-deparam'
if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	window.$.getScript 'cordova.js'
	
require 'ngCordova'
require 'angular-activerecord'
require 'angular-http-auth'
require './app.coffee'
require './controller.coffee'
require './model.coffee'