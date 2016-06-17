module.exports =
  file:
    opts:
      adapter: require 'skipper-gridfs'
      uri: 'mongodb://@file_mongo:27017/file'
      bucket: 'fs'
      maxBytes: 1024000 #10MB
      saveAs: (stream, next) ->
        # convert input wav stream to mp3 stream
        if sails.services.file.type(stream.filename) == 'audio/wave'
          stream = sails.services.audio.mp3 stream
        next null, stream.filename
