module.exports =
  bootstrap: (cb) ->
    sails.config.file.storage = sails.config.file.opts.adapter sails.config.file.opts
    user = ->
      sails.models.user
        .findOrCreate sails.config.user.admin
    root = ->
      sails.models.file
        .mkdir '/', sails.config.user.admin.email
    chmod = (root) ->
      cond =
        user: '.*'
        file: root.id
      sails.models.permission
        .update cond, mode: 7
    user()
      .then root
      .then chmod
      .then ->
        cb()
      .catch cb
