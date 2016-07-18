express = require 'express'

module.exports =
  http:
    middleware:
      static: express.static 'www'
      isAuth: (req, res, next) ->
        sails.models.user
          .findOrCreate
            email: req.headers['x-forwarded-email']
            name: req.headers['x-forwarded-user']
          .then (user) ->
            req.user = user
            next()
          .catch next
      mkHome: (req, res, next) ->
        sails.models.file
          .mkdir "/#{req.user.name}", req.user.email
          .then ->
            next()
          .catch next
      order: [
        'bodyParser'
        'compress'
        'isAuth'
        'mkHome'
        '$custom'
        'router'
        'static'
      ]
