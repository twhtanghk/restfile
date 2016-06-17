_ = require 'lodash'
Promise = require 'bluebird'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  params = actionUtil.parseValues req

  # check owner of first uploaded file
  owner = ->
    sails.models.file
      .findOne()
      .where filename: params.filename
      .sort uploadDate: 'asc'
      .then (file) ->
        if file?
          if file.metadata.createdBy == req.user
            Promise.resolve()
          else
            Promise.reject "#{params.filename} created by #{req.user}"
        else
          Promise.reject "not found"

  # check version exist
  exist = ->
    if params.version?
      switch true
        when typeof params.version == 'number'
          sails.config.file.storage
            .find params.filename, params.version
        when Array.isArray params.version
          Promise.map params.version, (v) ->
            sails.config.file.storage
              .find params.filename, v
        else
          Promise.reject "invalid version"
    else
      sails.config.file.storage
        .find params.filename, -1
        
  exist()
    .then ->
      owner()
        .then ->
          next()
        .catch res.forbidden
    .catch res.notFound
