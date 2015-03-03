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
		if (window.cordova)
			cordovaMetadata = cordova.require("cordova/plugin_list").metadata
			if cordovaMetadata.hasOwnProperty("org.apache.cordova.inappbrowser")
				cancel = (event) ->
					deferred.reject("The sign in flow was canceled")
				browserRef = window.open "#{oauth.url}?#{$.param(oauth.param)}", '_blank', 'location=no,clearsessioncache=yes,clearcache=yes'
				browserRef.addEventListener "loadstart", (event) ->
					if (event.url).indexOf('http://localhost/callback') == 0
						browserRef.removeEventListener 'exit', cancel
						browserRef.close()
						deferred.resolve $.deparam event.url.split("#")[1]
				browserRef.addEventListener 'exit', cancel
			else
				deferred.reject("Could not find InAppBrowser plugin")
		else
			deferred.reject("Cannot authenticate via a web browser")
            
		return deferred.promise
		
	fulfill = (data) =>
		$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
		authService.loginConfirmed()
				
	@scope.authProviders =
		'mob.myvnc.com':
			icon:	'img/google_32.png'
			key:	'fileappPRD'
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
				
FileCtrl = ($stateParams, @scope, model) ->
	@scope = angular.extend @scope,
		path:		$stateParams.path
		state:
			page:		1
			per_page:	10
		files:		[]
	
	success = (res) =>
		angular.extend @scope.state, res.state
		angular.forEach res.results, (file, index) =>
			@scope.files.push new model.File file, parse: true
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
angular.module('starter.controller').controller 'FileCtrl', ['$stateParams', '$scope', 'model', FileCtrl]