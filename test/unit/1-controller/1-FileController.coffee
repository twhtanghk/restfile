_ = require 'lodash'
path = require 'path'
req = require 'supertest-as-promised'

describe 'FileController', ->
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

  it "create #{files[0]}", (done) ->
    req sails.hooks.http.app
      .post '/file'
      .set 'x-forwarded-user', user[0].name
      .set 'x-forwarded-email', user[0].email
      .set 'Content-Type', 'multipart/form-data'
      .field 'filename', files[0]
      .attach 'file', files[0]
      .expect 200
      .then ->
        done()
      .catch done

  it "get #{files[0]} property", (done) ->
    req sails.hooks.http.app
      .get "/file/property?filename=#{files[0]}"
      .set 'x-forwarded-user', user[0].name
      .set 'x-forwarded-email', user[0].email
      .expect 200
      .then ->
         done()
      .catch done

  it "get #{files[0]} version", (done) ->
    req sails.hooks.http.app
      .get "/file/version?filename=#{files[0]}"
      .set 'x-forwarded-user', user[0].name
      .set 'x-forwarded-email', user[0].email
      .expect 200
      .then ->
         done()
      .catch done

  it "get #{files[0]} content", (done) ->
    req sails.hooks.http.app
      .get "/file?filename=#{files[0]}"
      .set 'x-forwarded-user', user[0].name
      .set 'x-forwarded-email', user[0].email
      .expect 200
      .then ->
         done()
      .catch done

  it "list files for non-existent folder", (done) ->
    req sails.hooks.http.app
      .get "/file/property?filename=/notFound"
      .set 'x-forwarded-user', user[0].name
      .set 'x-forwarded-email', user[0].email
      .expect 404
      .then ->
        done()
      .catch done

  _.each files, (file) ->
    it "put #{files[0]} content", (done) ->
      req sails.hooks.http.app
        .put "/file?filename=#{files[0]}"
        .set 'x-forwarded-user', user[0].name
        .set 'x-forwarded-email', user[0].email
        .set 'Content-Type', 'multipart/form-data'
        .field 'filename', files[0]
        .attach 'file', files[1]
        .expect 200
        .then ->
          done()
        .catch done

  ###
  _.each [2, [2,3]], (v) ->
     it "delete version #{JSON.stringify v} of #{files[0]}", (done) ->
      req sails.hooks.http.app
        .delete "/file?filename=#{files[0]}"
        .set 'x-forwarded-user', user[0].name
        .set 'x-forwarded-email', user[0].email
        .send version: v
        .expect 200
        .then ->
          done()
        .catch done
  ###

  it "delete #{files[0]}", (done) ->
    sails.models.file.exist files[0]
      .then (file) ->
        req sails.hooks.http.app
          .delete "/file/#{file.id}"
          .set 'x-forwarded-user', user[1].name
          .set 'x-forwarded-email', user[1].email
          .expect 403
          .then ->
            done()
      .catch done

  it "delete #{files[0]}", (done) ->
    sails.models.file.exist files[0]
      .then (file) ->
        req sails.hooks.http.app
          .delete "/file/#{file.id}"
          .set 'x-forwarded-user', user[0].name
          .set 'x-forwarded-email', user[0].email
          .expect 200
          .then ->
            done()
      .catch done

  it "mkdir #{path.dirname files[0]}", (done) ->
    req sails.hooks.http.app
      .post "/dir"
      .send filename: path.dirname files[0]
      .set 'x-forwarded-user', user[0].name
      .set 'x-forwarded-email', user[0].email
      .expect 200
      .then ->
        done()
      .catch done

  it "recursive delete /#{user[0].name}", (done) ->
    sails.models.file.exist "/#{user[0].name}"
      .then (dir) ->
        req sails.hooks.http.app
          .delete "/dir/#{dir.id}"
          .set 'x-forwarded-user', user[0].name
          .set 'x-forwarded-email', user[0].email
          .expect 200
          .then ->
            done()
      .catch done

  it "update /usr/src to /usr/src1", (done) ->
    sails.models.file.exist "/usr/src"
      .then (dir) ->
        req sails.hooks.http.app
          .put "/dir/#{dir.id}"
          .send filename: 'src1'
          .set 'x-forwarded-user', user[0].name
          .set 'x-forwarded-email', user[0].email
          .expect 200
          .then ->
            done()
      .catch done    
