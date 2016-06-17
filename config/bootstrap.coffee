module.exports =
  bootstrap: (cb) ->
    sails.config.file.storage = sails.config.file.opts.adapter sails.config.file.opts
    cb()
