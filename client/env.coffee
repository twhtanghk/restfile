_ = require 'underscore'
path = require 'path'

proj = 'file'
authServer = 'mppsrc.ogcio.hksarg'

env =
	user:
		url:	"https://#{authServer}/org/api/users/"
	path:		"/#{proj}"
	oauth2:
		clientID:		"#{proj}DEV"
		authUrl:		"https://#{authServer}/org/oauth2/authorize/"
		scope:			[
			"https://#{authServer}/org/users",
			"https://#{authServer}/file"
		]
	file:
		newfile:	'New File'
		newdir:		'New Folder'
	flash:
		timeout:	5000		# ms	
	icons:
		"text/directory":			"dir.png"
		"text/plain":				"txt.png"
		"text/html":				"html.png"
		"application/javascript":	"js.png"
		"application/octet-stream":	"dat.png"
		"application/excel":		"xls.png"
		"image/png":				"png.png"
	
_.each env.icons, (val, key) ->
	env.icons[key] = path.join(env.path, 'img', val)
			
module.exports = env