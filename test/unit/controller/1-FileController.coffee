_ = require 'lodash'
req = require 'supertest-as-promised'

describe 'FileController', ->
  @timeout 500000
	
  user = 'user@abc.com'
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
      .set 'x-forwarded-email', user
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
      .set 'x-forwarded-email', user
      .expect 200
      .then ->
         done()
      .catch done

  it "get #{files[0]} version", (done) ->
    req sails.hooks.http.app
      .get "/file/version?filename=#{files[0]}"
      .set 'x-forwarded-email', user
      .expect 200
      .then ->
         done()
      .catch done

  it "get #{files[0]} content", (done) ->
    req sails.hooks.http.app
      .get "/file?filename=#{files[0]}"
      .set 'x-forwarded-email', user
      .expect 200
      .then ->
         done()
      .catch done

  _.each files, (file) ->
    it "put #{files[0]} content", (done) ->
      req sails.hooks.http.app
        .put "/file?filename=#{files[0]}"
        .set 'x-forwarded-email', user
        .set 'Content-Type', 'multipart/form-data'
        .field 'filename', files[0]
        .attach 'file', files[1]
        .expect 200
        .then ->
          done()
        .catch done

  _.each [2, [2,3]], (v) ->
     it "delete version #{JSON.stringify v} of #{files[0]}", (done) ->
      req sails.hooks.http.app
        .delete "/file?filename=#{files[0]}"
        .set 'x-forwarded-email', user
        .send version: v
        .expect 200
        .then ->
          done()
        .catch done

  it "delete #{files[0]}", (done) ->
    req sails.hooks.http.app
      .delete "/file?filename=#{files[0]}"
      .set 'x-forwarded-email', user
      .expect 200
      .then ->
        done()
      .catch done
