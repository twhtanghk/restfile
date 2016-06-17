_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  params = actionUtil.parseValues req
  sails.models.file
    .findOne()
    .where filename: params.filename, 'metadata.createdBy': req.user
    .then (file) ->
      if file?
        next()
      else
        res.forbidden "#{params.filename} created by #{req.user}"
