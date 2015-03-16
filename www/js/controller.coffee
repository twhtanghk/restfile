env = require './env.coffee'

AppCtrl = ($rootScope, $scope, $http, platform, authService) ->	
	# state
	$scope = angular.extend $scope,
		mode:	'open'
		
	$rootScope.$on '$stateChangeStart', ->
		$scope.mode = 'open'
	
	# event
	# set authorization header once mobile authentication completed
	fulfill = (data) ->
		if data?
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
	
	events =
		'mode:open': ->
			$scope.mode = 'open'
		'mode:select': ->
			$scope.mode = 'select'
		'event:auth-forbidden': ->
			platform.auth().then fulfill, alert
		'event:auth-loginRequired': ->
			platform.auth().then fulfill, alert
			
	angular.forEach events, (handler, event) =>
		$scope.$on event, handler
		
	$scope.selectAll = ->
		$rootScope.$broadcast 'select:all'
		
	$scope.deselectAll = ->
		$rootScope.$broadcast 'deselect:all'
		
	$scope.destroySel = ->
		$rootScope.$broadcast 'destroy:selected'
		$scope.mode = 'open'
		
	$scope.cancel = ->
		$scope.deselectAll()
		$scope.mode = 'open'
		
MenuCtrl = ($rootScope, $scope) ->
	$scope.newFolder = =>
		$rootScope.$broadcast 'newFolder'
				
FileCtrl = ($scope, $stateParams, platform, model) ->
	# state
	$scope = angular.extend $scope,
		path:		$stateParams.path
		state:
			page:		1
			per_page:	10
		files:		[]
		platform:	platform
		
	# event
	events =
		'newFolder': ->
			$scope.create()
		'select:all': ->
			_.each $scope.files, (file) ->
				file.selected = true
		'deselect:all': ->
			_.each $scope.files, (file) ->
				file.selected = false
		'destroy:selected': ->
			_.each $scope.files, (file) ->
				if file.selected
					$scope.destroy file
					
	angular.forEach events, (handler, event) ->
		$scope.$on event, handler
		
	# create folder "New Folder" in current directory 
	$scope.create = =>
		folder = new model.File path: "#{$scope.path}New Folder/"
		folder.$save()
			.then ->
				$scope.files.push folder
			.catch alert
	
	# read/refresh first page of files under current directory
	getPage = (opts) =>
		model.File.fetchPage(opts)
			.then (res) ->
				angular.extend $scope.state, res.state
				angular.forEach res.results, (file, index) ->
					file = new model.File file, parse: true
					$scope.files.push file
				$scope.$broadcast('scroll.infiniteScrollComplete')
			.catch alert
		
	$scope.read = ->
		$scope.state.page = 1
		$scope.files = []
		opts =
			path:		$scope.path
			params:		$scope.state
		getPage(opts)
	
	# read next page of files under
	$scope.loadMore = ->
		opts =
			path:		$scope.path
			params:		$scope.state
		opts.params.page++
		getPage(opts)
		
	# update properties of specified file
	$scope.edit = (file) ->
		return
		
	# delete the specified file (delete folder not supported yet)
	$scope.destroy = (file) ->
		file.$destroy()
			.then ->
				$scope.state.count--
				deleted = file
				$scope.files = _.filter $scope.files, (file) ->
					file.path != deleted.path
			.catch alert
			
	$scope.nselected = ->
		(_.where $scope.files, selected: true).length
			
	model.User.me()
		.then (user) ->
			if $scope.path == null or $scope.path == ''
				$scope.path = "#{user.username}/"
			$scope.read()
		.catch alert 
		
config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$rootScope', '$scope', '$http', 'platform', 'authService', AppCtrl]
angular.module('starter.controller').controller 'MenuCtrl', ['$rootScope', '$scope', MenuCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$scope', '$stateParams', 'platform', 'model', FileCtrl]