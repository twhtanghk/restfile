path = require 'path'
mime = require 'mime-types/index.js'

module.exports =
  # get file id
  id: (fullpath) ->
    sails.models.file.findPath fullpath
      .then (file) ->
        file.id

  fullpath: (id) ->
    sails.models.file.findUp id: id
      .then (file) ->
        file.fullpath()
		
  type: (name) ->
    mime.lookup(name)
				
  isImg: (name) ->
    (/^image/i).test module.exports.type(name)

  isAudio: (name) ->
    (/^audio/i).test module.exports.type(name)
		
  thumbName: (filename) ->
    [fullname, name, ext] = filename.match /(.*)\.([^\.]*)/
    "#{name}.thumb.#{ext}"
