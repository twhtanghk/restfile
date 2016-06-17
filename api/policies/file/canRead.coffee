_ = require 'lodash'

module.exports = (req, res, next) ->
  req.options.where ?= {}
  _.extend req.options.where, 'metadata.createdBy': req.user
  next()
