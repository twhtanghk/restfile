envClient = require './client/env.coffee'
Promise = require 'promise'

Promise.timer = (p, ms = envClient.promise.timeout) ->
	return new Promise (fulfill, reject) ->
        task = null 
        success = (result) ->
            clearTimeout task
            fulfill(result)
        error = ->
            reject 'timeout to complete the task'
        task = setTimeout error, ms
        p.then success, reject
	
module.exports = Promise