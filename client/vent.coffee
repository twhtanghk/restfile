Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

vent = new Backbone.Wreqr.EventAggregator()

vent.on 'show:msg', (msg, type='info') =>
	require 'bootstrap.growl'
	$.growl {message: msg, type: type}

vent.error = (msg) ->
	$.growl {message: msg, type: 'error'}

module.exports = vent