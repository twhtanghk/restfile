env = require './env.coffee'

AppCtrl = (@rootScope, $http, platform, authService) ->		
	# set authorization header once mobile authentication completed
	fulfill = (data) ->
		if data?
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
				
	@rootScope.$on 'event:auth-forbidden', ->
		platform.auth().then fulfill, alert
	
	@rootScope.$on 'event:auth-loginRequired', ->
		platform.auth().then fulfill, alert
				
FileCtrl = ($stateParams, @scope, platform, model) ->
	@scope = angular.extend @scope,
		path:		$stateParams.path
		state:
			page:		1
			per_page:	10
		files:		[]
	
	success = (res) =>
		angular.extend @scope.state, res.state
		angular.forEach res.results, (file, index) =>
			file = new model.File file, parse: true
			file.open = ->
				platform.open(@)
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
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$rootScope', '$http', 'platform', 'authService', AppCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$stateParams', '$scope', 'platform', 'model', FileCtrl]