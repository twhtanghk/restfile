stream = require 'stream'
_ = require 'underscore'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
  dir: (req, res) ->
    params = actionUtil.parseValues req
    query = sails.models.file
      .find 'metadata.dirname': params.filename
      .where _.omit actionUtil.parseCriteria(req), 'filename'
      .limit actionUtil.parseLimit req
      .skip actionUtil.parseSkip req
      .sort actionUtil.parseSort req
    actionUtil.populateRequest query, req
      .then res.ok, res.serverError

  findAllVersion: (req, res) ->
    params = actionUtil.parseValues req
    query = sails.models.file
      .find()
      .where actionUtil.parseCriteria req
      .limit actionUtil.parseLimit req
      .skip actionUtil.parseSkip req
      .sort actionUtil.parseSort req
    actionUtil.populateRequest query, req

  findOne: (req, res) ->
    params = actionUtil.parseValues req
    version = params.version
    query = sails.models.file
      .findOne()
      .where _.omit actionUtil.parseCriteria(req), 'version'
      .limit -1
      .skip Math.abs(version) - 1
      .sort { uploadDate: if version < 0 then -1 else 1 }
    actionUtil.populateRequest query, req
      .then (file) ->
        if file?
          res.ok file
        else
          res.notFound()
      .catch res.serverError

  version: (req, res) ->
    module.exports.findAllVersion req, res
      .then res.ok, res.serverError

  content: (req, res) ->
    params = actionUtil.parseValues req
    sails.config.file.storage
      .read params.filename, params.version
      .then (stream) ->
        if stream?
          stream.pipe res
        else
          res.notFound()
      .catch res.serverError

  create: (req, res) ->
    class Transform extends stream.Transform

      constructor: (opts = {}) ->
        _.defaults opts, objectMode: true
        super opts
      _transform: (file, encoding, done) ->
        data = req.allParams()
        done null,  _.extend file, data, metadata: createdBy: req.user

    receiver = sails.config.file.storage.receive()
      .on 'error', res.serverError
      .on 'finish', res.ok

    req.file 'file'
      .on 'error', res.serverError
      .pipe new Transform()
      .pipe receiver

  update: (req, res) ->
    module.exports.create req, res

  destroy: (req, res) ->
    params = actionUtil.parseValues req
    sails.config.file.storage
      .rm params.filename, params.version
      .then res.ok, res.serverError
