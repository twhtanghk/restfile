AppCtrl = (@scope, ionicModal) ->
	ionicModal.fromTemplateUrl('templates/login.html', scope: @scope).then (modal) =>
		@scope.modal = modal

	@scope.closeLogin = =>
		@scope.modal.hide()
	
	@scope.login = =>
		@scope.modal.show()
		
	@scope.$on 'event:auth-forbidden', =>
		@scope.login()
	
	@scope.$on 'event:auth-loginRequired', =>
		@scope.login()
		
AuthCtrl = (@scope, auth, $q, $http, authService) ->
	auth.mob = (clientId, scope) ->
		oauth =
			url:	"https://mob.myvnc.com/org/oauth2/authorize/"
			param:
				response_type:	"token"
				client_id:		clientId
				redirectUrl:	"http://localhost/callback"
				scope:			scope
		deferred = $q.defer()
		cancel = (event) ->
			deferred.reject("The sign in flow was canceled")

		browserRef = window.open "#{oauth.url}?#{$.param(oauth.param)}", '_blank', 'location=no,clearsessioncache=no,clearcache=no'
		browserRef.addEventListener "loadstart", (event) ->
			if (event.url).indexOf('http://localhost/callback') == 0
				browserRef.removeEventListener 'exit', cancel
				browserRef.close()
				deferred.resolve $.deparam event.url.split("#")[1]
		browserRef.addEventListener 'exit', cancel    
		return deferred.promise
		
	fulfill = (data) =>
		$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
		authService.loginConfirmed()
				
	@scope.authProviders =
		'mob.myvnc.com':
			icon:	'img/google_32.png'
			key:	if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) then 'fileappPRD' else 'fileDEV'
			scope:	[
				"https://mob.myvnc.com/org/users"
				"https://mob.myvnc.com/file"
				"https://mob.myvnc.com/xmpp"
			].join(" ")
			action:	->
				auth.mob(@key, @scope).then fulfill, alert
		Google:
			icon: 	'img/google_32.png'
			key:	'796465438573-inn6q18ni4lno4tasc4vapcj99ib3udt.apps.googleusercontent.com'
			scope:	[ 'email' ]
			action:	->
				auth.google(@key, @scope).then fulfill, alert
				
FileCtrl = ($stateParams, @scope, $location, $window, $http, model) ->
	@scope = angular.extend @scope,
		path:		$stateParams.path
		state:
			page:		1
			per_page:	10
		files:		[]
	
	fserr = (err) ->
		msg = []
		msg[FileError.ENCODING_ERR] = 'ENCODING_ERR'
		msg[FileError.INVALID_MODIFICATION_ERR] = 'INVALID_MODIFICATION_ERR'
		msg[FileError.INVALID_STATE_ERR] = 'INVALID_STATE_ERR'
		msg[FileError.NO_MODIFICATION_ALLOWED_ERR] = 'NO_MODIFICATION_ALLOWED_ERR'
		msg[FileError.NOT_FOUND_ERR] = 'NOT_FOUND_ERR'
		msg[FileError.NOT_READABLE_ERR] = 'NOT_READABLE_ERR'
		msg[FileError.PATH_EXISTS_ERR] = 'PATH_EXISTS_ERR'
		msg[FileError.QUOTA_EXCEEDED_ERR] = 'QUOTA_EXCEEDED_ERR'
		msg[FileError.SECURITY_ERR] = 'SECURITY_ERR'
		msg[FileError.TYPE_MISMATCH_ERR] = 'TYPE_MISMATCH_ERR'
		alert msg[err.code]
	transferErr = (err) ->
		msg = []
		msg[FileTransferError.FILE_NOT_FOUND_ERR] = 'FILE_NOT_FOUND_ERR'
		msg[FileTransferError.INVALID_URL_ERR] = 'INVALID_URL_ERR'
		msg[FileTransferError.CONNECTION_ERR] = 'CONNECTION_ERR'
		msg[FileTransferError.ABORT_ERR] = 'ABORT_ERR'
		msg[FileTransferError.NOT_MODIFIED_ERR] = 'NOT_MODIFIED_ERR'
		alert msg[err.code]
	fs = (type, size) ->
		new Promise (fulfill, reject) ->
			$window.requestFileSystem type, size, fulfill, reject	
	download = (remote, local, trustAllHosts, opts) ->
		new Promise (fulfill, reject) ->
			fileTransfer = new FileTransfer()
			fileTransfer.download encodeURI(remote), local, fulfill, reject, trustAllHosts, opts 
	open = (local, trustAllCertificates) ->
		new Promise (fulfill, reject) ->
			cordova.plugins.bridge.open local, fulfill, reject, trustAllCertificates
	
	success = (res) =>
		angular.extend @scope.state, res.state
		angular.forEach res.results, (file, index) =>
			file = new model.File file, parse: true
			file.open = () ->
				if @contentType == "text/directory"
					$location.url("#{$location.url()}#{@path}")
				else
					fs(window.PERSISTENT, 0).then (fs) ->
						local = "#{fs.root.toURL()}#{file.path}"
						download(file.url, local, false, headers: $http.defaults.headers.common).then ->
							open(local).catch alert
						.catch transferErr
					.catch fserr
			@scope.files.push file
		@scope.$broadcast('scroll.infiniteScrollComplete')
		
	@scope.loadMore = =>
		opts =
			path:		@scope.path
			params:		@scope.state
		opts.params.page++
		model.File.fetchPage(opts).then success, alert
		
	fulfill = (user) =>
		if @scope.path == null or @scope.path == ''
			@scope.path = "#{user.username}/"
		opts =
			path:		@scope.path
			params:		@scope.state
		model.File.fetchPage(opts).then success, alert
		
	model.User.me().then fulfill, alert 
		
config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$scope', '$ionicModal', AppCtrl]
angular.module('starter.controller').controller 'AuthCtrl', ['$scope', '$cordovaOauth', '$q', '$http', 'authService', AuthCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$stateParams', '$scope', '$location', '$window', '$http', 'model', FileCtrl]