_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  params = actionUtil.parseValues req
  req.options.values ?= {}
  switch true
    when params.id and not params.filename?
      sails.services.file.fullpath params.id
        .then (fullpath) ->
          _.extend req.options.values, filename: fullpath
          next()
        .catch res.serverError
    when params.filename and not params.id?
      sails.services.file.id params.filename
        .then (id) ->
          _.extend req.options.values, id: id
          next()
        .catch res.serverError
    else
      next()
