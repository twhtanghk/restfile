require 'jquery'
require '../public/js/jso'
require 'bootstrap/dist/js/bootstrap'

# media query
Modernizr.load
	test: Modernizr.mq('only all')
	nope: 'js/css3-mediaqueries.js'
# audio
Modernizr.load
	test: Modernizr.audio
	nope: 'js/jquery.jplayer.js'
      
app = require './app.coffee'
new app.App()