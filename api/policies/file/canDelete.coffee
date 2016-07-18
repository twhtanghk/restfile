actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  pk = actionUtil.requirePk req
  sails.models.permission
    .canDelete req.user.email, pk
    .then ->
      next()
    .catch res.forbidden
