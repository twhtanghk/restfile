_ = require 'lodash'
path = require 'path'
stream = require 'stream'
Promise = require 'bluebird'
streamifier = require 'streamifier'

module.exports =
  tableName: 'file'
  schema: true
  autoPK: true
  attributes:
    filename:
      type: 'string'
      required: true
    parent:
      model: 'file'
    child:
      collection: 'file'
      via: 'parent'
    isFile:
      type: 'boolean'
      defaultsTo: true
    acl:
      collection: 'permission'
      via: 'file'
    createdBy:
      model: 'user'
      required: true
    updatedBy:
      model: 'user'
    fullpath: ->
      if @filename == '/'
        @filename
      else
        path.join @parent.fullpath(), @filename
  beforeCreate: (values, cb) ->
    if not values.parent?
      return cb()
    sails.models.permission
      .canWrite values.createdBy, values.parent
      .then ->
        cb()
      .catch cb
  afterCreate: (values, cb) ->
    # create default permission and set it to attribute acl
    Promise
      .all [
        sails.models.permission
          .findOrCreate 
            user: '.*'
            file: values.id
            createdBy: values.createdBy
        sails.models.permission
          .findOrCreate 
            user: values.createdBy
            file: values.id
            mode: 7
            createdBy: values.createdBy
      ]
      .then ->
        cb()
      .catch cb
  beforeUpdate: (values, cb) ->
    sails.models.permission
      .canWrite values.updatedBy, values.id
      .then ->
        cb()
      .catch cb
  beforeDestroy: (cond, cb) ->
    @find cond
      .populate 'child'
      .then (files) ->
        Promise
          .all Promise.map files, (file) ->
            if file.isFile
              return sails.models.fsfiles
                .destroy 'metadata.file': file.id
                .toPromise()
            if not file.isFile and file.child.length != 0
              return Promise.reject "non-empty folder #{file.filename}"
      .then ->
        cb()
      .catch cb
  existOne: (cond) ->
    @findOne cond
      .populate 'acl'
      .populate 'child'
      .then (file) ->
        if not file?
          return Promise.reject "#{JSON.stringify cond} not found"
        file
  findUp: (cond) ->
    @existOne cond
      .then (file) =>
        if file.filename == '/'
          return Promise.resolve file
        @findUp id: file.parent
          .then (parent) ->
            file.parent = parent
            file
  isAbsolute: (fullpath) ->
    try 
      fullpath = path.normalize fullpath
      if not path.isAbsolute fullpath
        return Promise.reject "non-absolute path #{fullpath}"
      Promise.resolve fullpath
    catch error
      return Promise.reject error 
  findPath: (fullpath) ->
    @isAbsolute fullpath
      .then (fullpath) =>
        if fullpath == '/'
          return @existOne filename: fullpath
        @findPath path.dirname fullpath
          .then (parent) =>
            @existOne {parent: parent.id, filename: path.basename fullpath}
              .then (file) ->
                file.parent = parent
                file
              .catch ->
                Promise.reject "#{fullpath} not found"
  exist: (fullpath) ->
    @findPath fullpath
  mkdir: (fullpath, user) ->
    @isAbsolute fullpath
      .then (fullpath) =>
        if fullpath == '/'
          return @findOrCreate {parent: null, filename: fullpath},
            parent: null
            filename: fullpath
            createdBy: user
            isFile: false
        @mkdir path.dirname(fullpath), user
          .then (parent) =>
            @findOrCreate {parent: parent.id, filename: path.basename fullpath},
              parent: parent.id
              filename: path.basename fullpath
              createdBy: user
              isFile: false
          .then =>
            @findPath fullpath
  dir: (fullpath, user) ->
    @exist fullpath
      .then (file) ->
        if file.isFile
          return Promise.reject "#{fullpath} is not a regular file"
        sails.models.permission
          .canIndex user, file.id
          .then ->
             file  
  rm: (fullpath, user) ->
    @isAbsolute fullpath
      .then (fullpath) =>
        @findPath fullpath
          .then (file) ->
            sails.models.permission
              .canDelete user, file.id
              .then ->
                file
          .then (curr) =>
            if not curr.isFile
              return Promise
                .all Promise.map curr.child, (file) =>
                  @rm path.join(curr.fullpath(), file.filename), user
                .then ->
                  curr
            else
              curr
          .then (curr) =>
            @destroy _.pick curr, 'id'
  # Promise to upload inStream content for specified filename, user
  upload: (filename, user, inStream) ->
    @exist filename
      .catch =>
        values =
          filename: path.dirname filename
          createdBy: user
        @mkdir path.dirname(filename), user
          .then (parent) =>
            @create
              parent: parent
              filename: path.basename filename
              createdBy: user
      .then (file) =>
        @findUp _.pick file, 'id'
      .then (file) ->
        class FStream extends stream.Readable
          _read: ->
            _.extend inStream,
              filename: filename
              metadata:
                uploadedBy: user
                file: file.id
            @push inStream
            @push null
        fstream = new FStream objectMode: true
        new Promise (resolve, reject) ->
          fstream
            .pipe sails.config.file.storage.receive()
            .on 'finish', ->
              resolve file
            .on 'error', reject
  # Promise to return readableStream for specified filename, user, version
  download: (filename, email, version = -1) ->
    @exist filename
      .then (file) ->
        sails.models.permission.canRead email, file.id
        file
      .then (file) =>
        @read file.id
  # Promise to return readableStream
  read: (id, version = -1) ->
    sails.models.fsfiles.findOne 'metadata.file': id
      .populate 'chunks', sort: n: 1
      .limit 1
      .skip Math.abs(version) - 1
      .sort { uploadDate: if version < 0 then -1 else 1 }
      .then (file) ->
        if not file?
          Promise.reject 'file not found'
        buffers = _.map file.chunks, (chunk) ->
          chunk.data
        ret = streamifier.createReadStream Buffer.concat(buffers, file.length)
        ret.length = file.length
        ret
