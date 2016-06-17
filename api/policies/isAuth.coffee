module.exports = (req, res, next) ->
  req.user = req.headers['x-forwarded-email']
  if req.user
    next()
  else
    res.status(401).send()
