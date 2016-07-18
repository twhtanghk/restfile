_ = require 'lodash'
path = require 'path'

describe 'User', ->
  @timeout 500000
	
  user = 
    name: 'user'
    email: 'user@abc.com'
  files = [
    '/usr/src/app/LICENSE'
    '/usr/src/app/README.md'
    '/usr/src/app/Dockerfile'
    '/usr/src/app/package.json'
    '/usr/src/app/app.js'
  ]

  it "create user #{user.email}", (done) ->
    sails.models.user
      .create user
      .then ->
        done()
      .catch done
