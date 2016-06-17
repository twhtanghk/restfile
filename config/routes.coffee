module.exports =
  routes:
    ###
    create file with filename, createdBy (derived by current login user)
    and file content in multipart form
    e.g. curl -D /tmp/h.txt -X POST -H "x-forwarded-email: user@abc.com" -H "Content-Type: multipart/form-data" -F "filename=/usr/src/app/package.json"  -F "file=@/usr/src/app/package.json" http://node-1337.service.consul:1337/file
    ###
    'POST /file':
      controller: 'FileController'
      action: 'create'

    ###
    list files under specified directory in "filename" parameter
    e.g. url -D /tmp/h.txt -H "x-forwarded-email: user@abc.com" http://node-1337.service.consul:1337/file/dir?filename=/usr/src/app
    ###
    'GET /dir':
      controller: 'FileController'
      action: 'dir'
      limit: 10
      sort:
        filename: 'asc'

    ###
    get file content of the specified "filename" parameter
    e.g. curl -D /tmp/h.txt -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file?filename=/usr/src/app/package.json&version=-2'
    ###
    'GET /file':
      controller: 'FileController'
      action: 'content'
      sort:
        uploadDate: 'desc'

    ###
    get property of all versions of the specified "filename" parameter
    e.g. curl -D /tmp/h.txt -H "x-forwarded-email: user@abc.com" http://node-1337.service.consul:1337/file/version?filename=/usr/src/app/package.json
    ###
    'GET /file/version':
      controller: 'FileController'
      action: 'version'
      sort:
        uploadDate: 'desc'

    ###
    get property of the specified version (default -1) of the 
    specified "filename" parameter
    e.g. curl -D /tmp/h.txt -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file/property?filename=/usr/src/app/package.json&version=-2'
    ###
    'GET /file/property':
      controller: 'FileController'
      action: 'findOne'
      sort:
        uploadDate: 'desc'

    ###
    update file content with filename, createdBy (derived by current login user)
    defined in multipart form
    e.g. curl -D /tmp/h.txt -X PUT -H "x-forwarded-email: user@abc.com" -H "Content-Type: multipart/form-data" -F "filename=/usr/src/app/package.json" -F "file=@/usr/src/app/package.json" http://node-1337.service.consul:1337/file
    ###
    'PUT /file':
      controller: 'FileController'
      action: 'update'

    ###
    rm file with filename, createdBy (derived by current login user)
    or only the specified versions
    e.g. 
      curl -D /tmp/h.txt -X DELETE -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file?filename=/usr/src/app/package.json'
      curl -D /tmp/h.txt -X DELETE -H "x-forwarded-email: user@abc.com" -H "Content-Type: application/json" -d '{"version": [-2, -4]}' 'http://node-1337.service.consul:1337/file?filename=/usr/src/app/package.json'
    ###
    'DELETE /file':
      controller: 'FileController'
      action: 'destroy'
