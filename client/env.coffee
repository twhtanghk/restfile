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
			"https://#{authServer}/file",
			"https://#{authServer}/xmpp"
		]
	file:
		newfile:	'New File'
		newdir:		'New Folder'
	icons:
		"text/directory":			"dir.png"
		"text/plain":				"txt.png"
		"text/html":				"html.png"
		"application/javascript":	"js.png"
		"application/octet-stream":	"dat.png"
		"application/excel":		"xls.png"
		"image/png":				"png.png"
	flash:
		timeout:	3000	# ms	
	promise:
		timeout:	300		# ms
	
_.each env.icons, (val, key) ->
	env.icons[key] = path.join(env.path, 'img', val)
			
module.exports = env