module.exports = (req, res, next) ->
  req.options.values ?= {}
  req.options.values.createdBy = req.user
  sails.log.debug "setOwner #{JSON.stringify req.options.values}"
  next()
