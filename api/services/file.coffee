mime = require 'mime-types/index.js'

module.exports =
  # get file properties
  get: (path) ->
    sails.models.gridFS.findOne path: path
		
  type: (name) ->
    mime.lookup(name)
				
  isImg: (name) ->
    (/^image/i).test module.exports.type(name)

  isAudio: (name) ->
    (/^audio/i).test module.exports.type(name)
		
  thumbName: (filename) ->
    [fullname, name, ext] = filename.match /(.*)\.([^\.]*)/
    "#{name}.thumb.#{ext}"
