_ = require 'lodash'
path = require 'path'

describe 'Permission', ->
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

  it "check root permission", (done) ->
    sails.models.file
      .findOne filename: '/'
      .populateAll()
      .then (file) ->
        ret = _.some file.acl, (perm) ->
          perm.user == '.*' and perm.mode == 7
        if ret
          done()
        else
          Promise.reject 'unexpected root file permission'
      .catch done
