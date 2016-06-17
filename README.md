restfile
========

Web Server with Restful API to provide file storage

Server API
==========

## File

* attributes

see [api/models/File.coffee](https://github.com/twhtang/restfile/blob/master/api/models/File.coffee]

* Create

POST /file
```
create file with filename, createdBy (derived by current login user) and file content in multipart form

e.g. curl -D /tmp/h.txt -X POST -H "x-forwarded-email: user@abc.com" -H "Content-Type: multipart/form-data" -F "filename=/usr/src/app/package.json"  -F "file=@/usr/src/app/package.json" http://node-1337.service.consul:1337/file
```

* List Directory

GET /dir
```
list files under specified directory in "filename" parameter
e.g. url -D /tmp/h.txt -H "x-forwarded-email: user@abc.com" http://node-1337.service.consul:1337/file/dir?filename=/usr/src/app
```

* Get file content

GET /file
```
get file content of the specified "filename" parameter
e.g. curl -D /tmp/h.txt -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file?filename=/usr/src/app/package.json&version=-2'
```

* Get file property of all versions

GET /file/version
```
get property of all versions of the specified "filename" parameter
e.g. curl -D /tmp/h.txt -H "x-forwarded-email: user@abc.com" http://node-1337.service.consul:1337/file/version?filename=/usr/src/app/package.json
```

* Get file property of specified version

GET /file/property
```
get property of the specified version (default -1) of the specified "filename" parameter
e.g. curl -D /tmp/h.txt -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file/property?filename=/usr/src/app/package.json&version=-2'

```

* Update file content

PUT /file
```
update file content with filename, createdBy (derived by current login user) defined in multipart form
e.g. curl -D /tmp/h.txt -X PUT -H "x-forwarded-email: user@abc.com" -H "Content-Type: multipart/form-data" -F "filename=/usr/src/app/package.json" -F "file=@/usr/src/app/package.json" http://node-1337.service.consul:1337/file

```

* Delete file

DELETE /file
```
rm all file versions with filename, createdBy (derived by current login user) or only the specified versions
e.g.
  curl -D /tmp/h.txt -X DELETE -H "x-forwarded-email: user@abc.com" 'http://node-1337.service.consul:1337/file?filename=/usr/src/app/package.json'
  curl -D /tmp/h.txt -X DELETE -H "x-forwarded-email: user@abc.com" -H "Content-Type: application/json" -d '{"version": [-2, -4]}' 'http://node-1337.service.consul:1337/file?filename=/usr/src/app/package.json'
```

Installation
============
* git clone https://github.com/twhtanghk/restfile
* create file/conf/production.coffee and customize the settings (optional)
* create file/conf/oauth2.conf with content listed below and update provider and relevant parameters
```
http_address = "0.0.0.0:4180"
upstreams = [
  "http://file.service.consul:1337"
]
provider = "github"
redirect_url = "http://file_oauth2.service.consul:4180/oauth2/callback"
login_url = "https://github.com/login/oauth/authorize"
redeem-url = "https://github.com/login/oauth/access_token"
validate_url = "https://api.github.com/user/emails"
request_logging = true
pass_basic_auth = true
pass_host_header = true
email_domains = [
  "gmail.com"
]
client_id = "client id"
client_secret = "client secret"
cookie_secret = "0123456789012345"
cookie_secure = false

```
* export COMPOSE_OPTIONS="-e COMPOSEROOT=${PWD}"
* docker-compose -f docker-compose.yml up -d
* curl http://[ip or file.service.consul]:1337/file?...  

Test
====
* docker exec -it file bash
* (cd /usr/src/app; npm test)
