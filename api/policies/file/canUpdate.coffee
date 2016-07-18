_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  params = actionUtil.parseValues req
  sails.models.file
    .findOneByUser params.filename, req.user.email
    .then (file) ->
      if file?
        next()
      else
        res.notFound "#{params.filename} not found"
