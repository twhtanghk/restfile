path = require 'path'
stream = require 'stream'
Promise = require 'bluebird'
_ = require 'underscore'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

upload = (req, res) ->
  new Promise (resolve, reject) ->
    class FStream extends stream.Writable
      constructor: (opts = {}) ->
        _.defaults opts, objectMode: true
        super opts
      _write: (file, encoding, done) ->
        data = req.allParams()
        _.extend file, data, metadata: createdBy: req.user
        sails.models.file
          .upload data.filename, req.user.email, file
          .then (file) ->
            resolve file
            done()
          .catch done
    fstream = new FStream()
      .on 'error', reject
    req.file 'file'
      .on 'error', reject
      .pipe fstream

module.exports =
  findAllVersion: (req, res) ->
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
    sails.models.file
      .exist params.filename
      .then res.ok
      .catch res.notFound

  version: (req, res) ->
    module.exports.findAllVersion req, res
      .then res.ok, res.serverError

  content: (req, res) ->
    params = actionUtil.parseValues req
    sails.models.file.download params.filename, req.user.email
      .then (stream) ->
        res.attachment encodeURIComponent path.basename params.filename
        res.set 'Content-Length', stream.length
        stream
          .pipe res
          .on 'finish', res.end
          .on 'error', Promise.reject
      .catch res.serverError

  create: (req, res) ->
    upload req, res
      .then res.ok, res.serverError

  update: (req, res) ->
    switch true
      when req.is 'multipart/form-data'
        upload req, res
          .then res.ok, res.serverError
      else
        values = actionUtil.parseValues req
        sails.models.file.update _.pick(values, 'id'), _.pick(values, 'filename')
          .then res.ok, res.serverError
