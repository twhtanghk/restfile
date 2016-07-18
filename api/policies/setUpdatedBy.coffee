module.exports = (req, res, next) ->
  req.options.values ?= {}
  req.options.values.updatedBy = req.user.email
  next()
