_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  params = actionUtil.parseValues req
  if not params.version?
    req.options.values ?= {}
    _.extend req.options.values, version: -1
  next()
