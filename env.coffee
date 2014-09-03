proj = 'file'
path = "/#{proj}"
authServer = 'mppsrc.ogcio.hksarg'
url = "https://#{authServer}/org"
serverUrl =	"http://localhost:3000/#{proj}"

env =
	proj:	proj
	role:
		all:	'All Users'
		admin:	'Admin'
	serverUrl:	"http://localhost:3000/#{proj}"
	path:		path
	file:
		uploadDir:	"#{__dirname}/uploads"
		mode:		parseInt('0700', 8)
	dbUrl:		"mongodb://filerw:pass1234@localhost/file"
	oauth2:
		authorizationURL:	"#{url}/oauth2/authorize/"
		tokenURL:			"#{url}/oauth2/token/"
		profileURL:			"#{url}/api/users/me"
		verifyURL:			"#{url}/oauth2/verify/"
		callbackURL:		"#{serverUrl}/auth/provider/callback"
		provider:			require 'passport-ttsoon'
		authURL:			"/auth/provider"
		cbURL:				"/auth/provider/callback"
		clientID:			"#{proj}DEVAuth"
		clientSecret:		'pass1234'
		scope:		[
			"https://#{authServer}/org/users"
		]
	pageSize:	10
	log4js: 	require 'log4js'
	
env.log4js.configure
	appenders:	[ type: 'console' ]
	
module.exports = env