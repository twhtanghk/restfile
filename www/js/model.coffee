require 'angular-activerecord'
require 'ng-file-upload'
_ = require 'lodash'
path = require 'path'
Promise = require 'bluebird'

angular.module 'starter.model', ['ActiveRecord', 'ngFileUpload']
  .factory 'resource', (ActiveRecord, Upload) ->
    class Model extends ActiveRecord
      constructor: (attrs = {}, opts = parse: true) ->
        @$initialize attrs, opts

      $parse: (data, opts) ->
        ret = super data, opts
        _.each ['updatedAt', 'createdAt'], (field) ->
          ret[field] ?= new Date Date.parse ret[field]
        return ret

    class User extends Model
      $idAttribute: 'email'

      $urlRoot: 'user'

      _me = null

      home: ->
        "/#{@name}"

      @me: ->
        _me ?= new User email: 'me'

    class File extends Model
      $urlRoot: 'file'

      $parse: (data, opts) ->
        ret = super(data, opts) 

        if ret.parent
          ret.parent = new Dir ret.parent

        return ret        

      fullpath: ->
        if not @parent?
          @filename
        else
          path.join @parent.fullpath(), @filename

    class Dir extends File
      $urlRoot: 'dir'

      $parse: (data, opts) ->
        ret = super data, opts
        child = []
        _.each ret.child, (file) ->
          if file.isFile
            child.push new File file
          else
            child.push new Dir file
        ret.child = child
        return ret

      chdir: (dir) ->
        if dir?
          @id = dir.id
        else
          delete @id
        @$fetch
          reset: true

      up: ->
        if @parent?
          @id = @parent.id
          @$fetch reset: true

      mkdir: (dir = 'New Folder') ->
        newdir = new Dir()
        newdir
          .$save {},
            params:
              filename: path.join(@fullpath(), dir)
          .then (dir) =>
            @child.push dir
            @

      upload: (files, progress) ->
        if not Array.isArray files 
          @upload [files]
        else
          Promise
            .map files, (file) =>
              saved = new File()
              resolve = (uploaded) =>
                @child.push new File uploaded.data
              Upload
                .upload
                  url: saved.$urlRoot
                  headers:
                    'Content-Type': 'multipart/form-data'
                  data: 
                    filename: path.join @fullpath(), file.name
                    file: file
                .then resolve, Promise.reject, progress

    User: User
    File: File
    Dir: Dir
