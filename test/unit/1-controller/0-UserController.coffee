_ = require 'lodash'
req = require 'supertest-as-promised'

describe 'UserController', ->
  @timeout 500000
	
  user = 
    name: 'user'
    email: 'user@abc.com'

  it "get user details #{user.email}", (done) ->
    req sails.hooks.http.app
      .get '/user/me'
      .set 'x-forwarded-user', user.name
      .set 'x-forwarded-email', user.email
      .expect 200
      .then ->
        done()
      .catch done

  it "get registered user list", (done) ->
    req sails.hooks.http.app
      .get '/user'
      .set 'x-forwarded-user', user.name
      .set 'x-forwarded-email', user.email
      .expect 200
      .then ->
        done()
      .catch done
