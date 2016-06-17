_ = require 'lodash'
path = require 'path'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  params = actionUtil.parseValues req
  base = path.basename params.filename
  dir = path.dirname params.filename
  sails.models.file
    .findOne()
    .where 'metadata.dirname': dir
    .sort uploadDate: 'asc'
    .then (file) ->
      if file?
        if file.metadata.createdBy == req.user
          next()
        else
          res.forbidden "#{params.filename} under #{dir} created by #{file.createdBy}"
      else
        next()
