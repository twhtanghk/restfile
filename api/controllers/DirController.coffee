path = require 'path'
Promise = require 'bluebird'
_ = require 'underscore'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
  create: (req, res) ->
    params = actionUtil.parseValues req
    sails.models.file
      .mkdir params.filename, params.createdBy
      .then res.ok, res.serverError

  findOne: (req, res) ->
    dir = null
    try
      pk = actionUtil.requirePk req
      dir = sails.models.file
        .findUp id: pk
    catch error
      dir = sails.models.file
        .exist "/#{req.user.name}"
    finally
      dir
        .then (file) ->
          sails.models.file.dir file.fullpath(), req.user.email
        .then res.ok, res.serverError

  destroy: (req, res) ->
    pk = actionUtil.requirePk req
    sails.models.file
      .findUp id: pk
      .then (file) ->
        if file.isFile
          return res.forbidden "rmdir a regular file"
        file
      .then (dir) ->
        sails.models.file.rm dir.fullpath(), req.user.email
          .then res.ok, res.serverError
