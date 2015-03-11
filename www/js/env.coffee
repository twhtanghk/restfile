module.exports =
	isMobile:	->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	authUrl:	'https://mob.myvnc.com'
	serverUrl:	->
		if @isMobile() then 'https://mob.myvnc.com' else 'http://localhost:3000'
	oauth2: ->
		authUrl: "#{@authUrl}/org/oauth2/authorize/"
		opts:
			response_type:	"token"
			scope:			"https://mob.myvnc.com/org/users https://mob.myvnc.com/file https://mob.myvnc.com/xmpp"
			client_id:		if @isMobile() then 'fileappPRD' else 'fileDEV'
			redirectUrl:	if @isMobile() then 'http://localhost/callback' else 'http://localhost:3000/file/'