module.exports =
  routes:
    ###
    get details of current login user
    e.g. curl -D /tmp/h.txt -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" http://node-1337.service.consul:1337/user/me
    ###
    'GET /user/:id':
      controller: 'UserController'
      action: 'findOne'

    ###
    get list of registered users
    ###
    'GET /user':
      controller: 'UserController'
      action: 'find'

    ###
    create file with filename, createdBy (derived by current login user)
    and file content in multipart form
    e.g. curl -D /tmp/h.txt -X POST -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" -H "Content-Type: multipart/form-data" -F "filename=/usr/src/app/package.json"  -F "file=@/usr/src/app/package.json" http://node-1337.service.consul:1337/file
    ###
    'POST /file':
      controller: 'FileController'
      action: 'create'

    ###
    get file content of the specified "filename" parameter
    e.g. curl -D /tmp/h.txt -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file?filename=/usr/src/app/package.json&version=-2'
    ###
    'GET /file/:id?':
      controller: 'FileController'
      action: 'content'
      sort:
        uploadDate: 'desc'

    ###
    get property of all versions of the specified "filename" parameter
    e.g. curl -D /tmp/h.txt -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" http://node-1337.service.consul:1337/file/version?filename=/usr/src/app/package.json
    ###
    'GET /file/version':
      controller: 'FileController'
      action: 'version'
      sort:
        uploadDate: 'desc'

    ###
    get property of the specified version (default -1) of the 
    specified "filename" parameter
    e.g. curl -D /tmp/h.txt -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file/property?filename=/usr/src/app/package.json&version=-2'
    ###
    'GET /file/property':
      controller: 'FileController'
      action: 'findOne'
      sort:
        uploadDate: 'desc'

    ###
    update file content with filename, createdBy (derived by current login user)
    defined in multipart form
    e.g. curl -D /tmp/h.txt -X PUT -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" -H "Content-Type: multipart/form-data" -F "filename=/usr/src/app/package.json" -F "file=@/usr/src/app/package.json" http://node-1337.service.consul:1337/file
    ###
    'PUT /file':
      controller: 'FileController'
      action: 'update'

    ###
    rm file with filename, createdBy (derived by current login user)
    or only the specified versions
    e.g. 
      curl -D /tmp/h.txt -X DELETE -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file?filename=/usr/src/app/package.json'
      curl -D /tmp/h.txt -X DELETE -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" -H "Content-Type: application/json" -d '{"version": [-2, -4]}' 'http://node-1337.service.consul:1337/file/:id'
    ###
    'DELETE /file/:id':
      controller: 'FileController'
      action: 'destroy'

    ###
    add file permission
    e.g. 
      curl -D /tmp/h.txt -X POST -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" -d '{"user": ".*", "file": "/usr/src/app/package.json", mode: 7}' 'http://node-1337.service.consul:1337/permission?filename=/usr/src/app/package.json'
    ###
    'POST /permission':
      controller: 'PermissionController'
      action: 'create'

    ###
    delete file permission
    e.g.
      curl -D /tmp/h.txt -X DELETE -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/permission/:id'
    ###
    'DELETE /permissioin/:id':
      controller: 'PermissionController'
      action: 'destroy'

    ###
    create dir for "filename" parameter
    e.g. curl -D /tmp/h.txt -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" -H "Content-Type: application/json" -d '{"filename": "/usr/src/New Folder"}' http://node-1337.service.consul:1337/dir
    ###
    'POST /dir':
      controller: 'DirController'
      action: 'create'

    ###
    get dir details for "filename" parameter
    e.g. curl -D /tmp/h.txt -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" -H "Content-Type: application/json" -d '{"filename": "/usr/src/New Folder"}' http://node-1337.service.consul:1337/dir/:id
    ###
    'GET /dir/:id?':
      controller: 'DirController'
      action: 'findOne'

    ###
    put dir details for "filename" parameter
    e.g. curl -D /tmp/h.txt -X PUT -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" -H "Content-Type: application/json" -d '{"filename": "Folder"}' http://node-1337.service.consul:1337/dir/:id
    ###
    'PUT /dir/:id':
      controller: 'FileController'
      action: 'update'

    ###
    delete dir for "filename" parameter
    e.g. curl -D /tmp/h.txt -X DELETE -H "x-forwarded-user: user" -H "x-forwarded-email: user@abc.com" -H "Content-Type: application/json" -d '{"filename": "/usr/src/New Folder"}' http://node-1337.service.consul:1337/dir
    ###
    'DELETE /dir/:id':
      controller: 'DirController'
      action: 'destroy'
