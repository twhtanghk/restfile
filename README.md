restfile
========

Web Server with Restful API to provide File Storage

API
===

```
get api/tag - get all file tags of current login user
post api/file/:path - create file or folder under current login user home directory
get api/file/:path - get properties (e.g. filename, tags) of the specified file or folder 
put api/file/:path - update details (e.g. filename, tags, content) of the specified file or folder
del api/file/:path - delete the specified file or folder
get :path - get content of the specified file or folder
```

Configuration
=============

*   git clone https://github.com/twhtanghk/restfile.git
*   cd restfile
*   bower install
*   npm install
*	npm run-script dev
*   update the following environment variables in start.sh, env.cofffee, and client/env.coffee
    
```
    PORT=3000
```

```
	authServer = 'mob.myvnc.com'
	
	file:
		uploadDir:	"#{__dirname}/uploads"
	dbUrl:		"mongodb://#{proj}rw:password@localhost/#{proj}"
	oauth2:
		clientID:			"#{proj}Auth"
		clientSecret:		'password'
```

```
	authServer = 'mob.myvnc.com'
```

*	create the uploadDir specified in env.coffee
*	create mongo database
*	npm start