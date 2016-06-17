Promise = require 'bluebird'
Sails = require 'sails'
fs = require 'fs'
config = JSON.parse fs.readFileSync './.sailsrc'
timeout = 50000000

before (done) ->
  @timeout timeout

  Sails.lift = Promise.promisify Sails.lift
  Sails.lift config
    .then (sails) ->
      done null, sails
    .catch done
		
after (done) ->
  Sails.lower done
