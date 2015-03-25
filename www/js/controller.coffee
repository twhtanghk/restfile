env = require './env.coffee'

AppCtrl = ($rootScope, $scope, $http, platform, authService) ->	
	# state
	$scope = _.extend $scope,
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
		'select:file': (file, selected)->
			$scope.mode = 'select'
		'event:auth-forbidden': ->
			platform.auth().then fulfill, alert
		'event:auth-loginRequired': ->
			platform.auth().then fulfill, alert
			
	_.each events, (handler, event) =>
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
				
FileCtrl = ($scope, $ionicModal, model) ->
	class FileView
	
		constructor: (opts = {}) ->
			@model = opts.model
			
		# update properties of specified file
		edit: (file) ->
			$ionicModal.fromTemplateUrl('templates/edit.html', scope: $scope).then (modal) =>
				$scope.modal = modal
				$scope.modal.show()
				
		remove: (file) ->
			file.$destroy()
				.then ->
					$scope.collection.remove file
				.catch alert
			
	$scope.controller = new FileView(model: $scope.file)
	
	$scope.$watchCollection 'file.tags', (newtags, oldtags) ->
		if newtags.length != oldtags.length
			$scope.file.$save().catch alert

FileListCtrl = ($scope, $stateParams, model) ->
	class FileListView
		# event
		events:
			'newFolder':	'create'
			'select:all':	'selectall'
			'deselect:all':	'deselectall' 
			
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
				
			@path = opts.path
			@collection = new model.FileList([], path: @path)
			@loadMore()
		
		selectall: =>
			_.each @collection.models, (file) ->
				file.selected = true
				
		deselectall: =>
			_.each @collection.models, (file) ->
				file.selected = false
		
		# create folder "New Folder" in current directory 
		create: =>
			folder = new model.File path: "#{@path}New Folder/"
			folder.$save()
				.then =>
					@collection.add folder
				.catch alert
	
		# read next page of files under current path
		loadMore: ->
			@collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
					
	model.User.me()
		.then (user) =>
			$scope.controller = new FileListView(path: $stateParams.path || "#{user.username}/")
			$scope.collection = $scope.controller.collection
		.catch alert
		
config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$rootScope', '$scope', '$http', 'platform', 'authService', AppCtrl]
angular.module('starter.controller').controller 'MenuCtrl', ['$rootScope', '$scope', MenuCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$scope', '$ionicModal', 'model', FileCtrl]
angular.module('starter.controller').controller 'FileListCtrl', ['$scope', '$stateParams', 'model', FileListCtrl]