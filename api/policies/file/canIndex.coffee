actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  values = actionUtil.parseValues req
  sails.models.permission
    .canIndex req.user.email, values.filename
    .then ->
      next()
    .catch next
