module.exports =
	isMobile:	->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	platform: ->
		if @isMobile() then 'mobile' else 'browser'
	authUrl:	'https://mob.myvnc.com'
	serverUrl:	->
		'https://mob.myvnc.com'
	oauth2: ->
		authUrl: "#{@authUrl}/org/oauth2/authorize/"
		opts:
			response_type:	"token"
			scope:			"https://mob.myvnc.com/org/users https://mob.myvnc.com/file https://mob.myvnc.com/xmpp"
			client_id:		if @isMobile() then 'fileappPRD' else 'fileDEV'
			redirectUrl:	if @isMobile() then 'http://localhost/callback' else 'http://localhost:3000/file/'