restfile
========

Web Server with Restful API to provide File Storage

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