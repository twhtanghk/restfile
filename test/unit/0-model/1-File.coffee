_ = require 'lodash'
fs = require 'fs'
path = require 'path'

describe 'File', ->
  @timeout 500000
	
  user = [
    {name: 'user1', email: 'user1@abc.com'}
    {name: 'user2', email: 'user2@abc.com'}
  ]
  files = [
    '/usr/src/app/LICENSE'
    '/usr/src/app/README.md'
    '/usr/src/app/Dockerfile'
    '/usr/src/app/package.json'
    '/usr/src/app/app.js'
  ]

  it "check non-existence of #{path.dirname files[0]}", (done) ->
    sails.models.file
      .exist path.dirname(files[0])
      .then ->
        done new Error 'unexpected result'
      .catch ->
        done()

  it "mkdir #{path.dirname files[0]}", (done) ->
    sails.models.file
      .mkdir path.dirname(files[0]), user[0].email
      .then ->
        done()
      .catch done

  it "upload #{files[0]}", (done) ->
    sails.models.file
      .upload files[0], user[0].email, fs.createReadStream(files[0])
      .then ->
        sails.models.file
          .findOne filename: 'app'
          .populateAll()
          .then (dir) ->
            if dir.acl.length == 0
              Promise.reject 'no default acl'
            done()
      .catch done

  it "upload #{files[0]}", (done) ->
    sails.models.file
      .upload files[0], user[0].email, fs.createReadStream(files[1])
      .then ->
        done()
      .catch done

  it "download #{files[0]}", (done) ->
    sails.models.file
      .download files[0], user[0].email
      .then (fstream) ->
        fstream.pipe fs.createWriteStream "/tmp/#{path.basename files[1]}"
          .on 'finish', ->
            done()
          .on 'error', done
      .catch done

  it "download #{files[0]}", (done) ->
    sails.models.file
      .download files[0], user[0].email, -2
      .then (fstream) ->
        fstream.pipe fs.createWriteStream "/tmp/#{path.basename files[0]}"
          .on 'finish', ->
            done()
          .on 'error', done
      .catch done

  it "check existence of #{path.dirname files[0]}", (done) ->
    sails.models.file
      .exist path.dirname(files[0]), user[0].email
      .then (exist) ->
        if exist
          done()
        else
          Promise.reject 'unexpected result'
      .catch done

  it "list file #{path.dirname files[0]}", (done) ->
    sails.models.file
      .exist path.dirname files[0]
      .then (file) ->
        if file.child.length != 1
          return done new Error 'unexpected result'
        done()
      .catch done

  it "recursive delete dir /usr", (done) ->
    sails.models.file
      .rm '/usr', user[0].email
      .then ->
        sails.models.file.findPath files[0]
          .then ->
            Promise.reject 'unexpected result'
          .catch ->
            done()
      .catch done
