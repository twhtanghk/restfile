Promise = require 'bluebird'

module.exports =
  tableName: 'fs.files'
  schema: true
  autoPK: true
  attributes:
    contentType:
      type: 'string'
    length:
      type: 'integer'
    uploadDate:
      type: 'datetime'
    metadata:
      type: 'json'
    md5:
      type: 'string'
    chunks:
      collection: 'fschunks'
      via: 'files_id'
  beforeDestroy: (cond, cb) ->
    @find cond
      .then (files) ->
        Promise
          .all Promise.map files, (file) ->
            sails.models.fschunks
              .destroy files_id: file.id
              .toPromise()
      .then ->
        cb()
      .catch cb
