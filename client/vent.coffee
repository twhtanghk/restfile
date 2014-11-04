Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

vent = new Backbone.Wreqr.EventAggregator()

vent.on 'show:msg', (msg, type='info') =>
	require 'bootstrap.growl'
	$.growl {message: msg, type: type}

module.exports = vent