_ = require 'lodash'

module.exports =
  tableName: 'permission'
  schema: true
  autoPK: true
  attributes:
    file:
      model: 'file'
    user:
      type: 'string'
      required: true
    mode:
      type: 'integer'
      defaultsTo: 0 # default permission is none
    createdBy:
      model: 'user'
      required: true
  read: (right) ->
    right & 4
  write: (right) ->
    right & 2
  index: (right) ->
    right & 1
  # user: user email address
  # file: file id of sails.models.file
  can: (user, file, op) ->
    if file
      sails.models.file
        .findUp id: file
        .then (file) ->
          ret = _.some file.acl, (perm) ->
            user.match(new RegExp perm.user) and op perm.mode
          if ret
            Promise.resolve ret
          else
            opstr = switch op
              when @write
                'write'
              when @read
                'read'
              when @index
                'index'
            Promise.reject "#{user} is unauthorized to #{opstr} #{file.fullpath()}"
    else
      Promise.resolve true
  canIndex: (user, file) ->
    @can user, file, @index
      .catch (err) ->
  canRead: (user, file) ->
    @can user, file, @read
  canWrite: (user, file) ->
    @can user, file, @write
  canDelete: (user, file) ->
    @can user, file, @write
