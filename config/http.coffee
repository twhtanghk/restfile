module.exports =
  http:
    middleware:
      dump: (req, res, next) ->
        sails.log.debug req.headers
        sails.log.debug req.body
        next()
      order: [
        'bodyParser'
        'compress'
#        'dump'
        '$custom'
        'router'
      ]
