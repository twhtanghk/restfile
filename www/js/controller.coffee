env = require './env.coffee'

AppCtrl = (@scope, ionicModal) ->
	ionicModal.fromTemplateUrl('templates/login.html', scope: @scope).then (modal) =>
		@scope.modal = modal

	@scope.closeLogin = =>
		@scope.modal.hide()
	
	@scope.login = =>
		@scope.modal.show()
		
AuthCtrl = (@rootScope, @scope, auth, $q, $http, $cordovaInAppBrowser, authService) ->
	auth.mob = (clientId, scope) =>
		deferred = $q.defer()
		url = "#{env.oauth2().authUrl}?#{$.param(env.oauth2().opts)}"
		mobile = =>
			document.addEventListener 'deviceready', ->
				$cordovaInAppBrowser.open(url, '_blank')
			
			@rootScope.$on '$cordovaInAppBrowser:loadstart', (e, event) ->
				if (event.url).indexOf('http://localhost/callback') == 0
					$cordovaInAppBrowser.close()
					deferred.resolve $.deparam event.url.split("#")[1]
			
			@rootScope.$on '$cordovaInAppBrowser:exit', (e, event) ->
				deferred.reject("The sign in flow was canceled")    
		browser = ->
			window.location.href = url
		
		if env.isMobile()
			mobile()
		else
			browser()
			
		return deferred.promise
		
	fulfill = (data) =>
		$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
		authService.loginConfirmed()
				
	@scope.$on 'event:auth-forbidden', =>
		auth.mob().then fulfill, alert
	
	@scope.$on 'event:auth-loginRequired', =>
		auth.mob().then fulfill, alert
				
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
		
config =  ($cordovaInAppBrowserProvider) ->
	opts = 
		location: 'no'
		clearsessioncache: 'no'
		clearcache: 'no'
		toolbar: 'no'
		
	document.addEventListener 'deviceready', ->
		$cordovaInAppBrowserProvider.setDefaultOptions(opts)
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model']).config ['$cordovaInAppBrowserProvider', config]	
angular.module('starter.controller').controller 'AppCtrl', ['$scope', '$ionicModal', AppCtrl]
angular.module('starter.controller').controller 'AuthCtrl', ['$rootScope', '$scope', '$cordovaOauth', '$q', '$http', '$cordovaInAppBrowser', 'authService', AuthCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$stateParams', '$scope', '$location', '$window', '$http', 'model', FileCtrl]