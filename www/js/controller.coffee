env = require './env.coffee'

AppCtrl = ($rootScope, $scope, $http, platform, authService, model) ->	
	# set authorization header once mobile authentication completed
	fulfill = (data) ->
		if data?
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
	
	$scope.$on 'event:auth-forbidden', ->
		platform.auth().then fulfill, alert
	$scope.$on 'event:auth-loginRequired', ->
		platform.auth().then fulfill, alert
	
MenuCtrl = ($rootScope, $scope) ->
	$scope.newFolder = =>
		$rootScope.$broadcast 'newFolder'
				
FileCtrl = ($rootScope, $scope, $stateParams, $location, $ionicModal, model) ->
	class FileView
	
		events:
			'change:folder':	'cd'
			'new:folder':		'md'
		
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@model = opts.model
			
		home: =>
			@cd()
		
		cd: (folder) ->
			loc = (folder) ->
				$location.url("file/list/#{folder}")
			if _.isEmpty folder or _.isNull folder or _.isUndefined folder
				model.User.me()
					.then (user) ->
						loc("#{user.username}/")
					.catch alert
			else
				loc(folder)
			
		md: (folder = 'New Folder/') ->
			folder = new model.File path: "#{@model.path}#{folder}"
			folder.$save()
				.then =>
					@model.add folder
				.catch alert
				
		# read next page of files under current path
		loadMore: ->
			@model.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
		
		# update properties of specified file
		edit: ->
			$ionicModal.fromTemplateUrl('templates/edit.html', scope: $scope).then (modal) =>
				$scope.model.newname = $scope.model.name
				$scope.modal = modal
				$scope.modal.show()
				
		remove: (file) ->
			file.$destroy()
				.then =>
					@model.remove file
				.catch alert
			
		upload: (files) ->
			_.each files, (local) =>
				remote = (_.findWhere @model.models, name: local.name) || new model.File path: "#{@model.path}#{local.name}"
				remote.$save {file: local}
					.then =>
						@model.add remote
					.catch alert
			
	if $scope.model?
		$scope.controller = new FileView(model: $scope.model)
	else if $stateParams.path != ''
		$scope.model = new model.File path: $stateParams.path
		$scope.controller = new FileView(model: $scope.model)
		$scope.controller.loadMore()
	else
		$scope.controller = new FileView(model: $scope.model)
		$scope.controller.home()
		
	$scope.$watchCollection 'files', (newfiles, oldfiles) ->
		if newfiles?.length? and newfiles?.length != oldfiles?length
			$scope.controller.upload newfiles
		
	$scope.$watchCollection 'model.tags', (newtags, oldtags) ->
		if newtags?.length != oldtags?.length
			$scope.model.$save().catch alert
			
	###
	$scope.$watch 'model.path', (newpath, oldpath) ->
		if newpath != oldpath
			$scope.controller.cd(newpath)
	###
			
config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$rootScope', '$scope', '$http', 'platform', 'authService', 'model', AppCtrl]
angular.module('starter.controller').controller 'MenuCtrl', ['$rootScope', '$scope', MenuCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$rootScope', '$scope', '$stateParams', '$location', '$ionicModal', 'model', FileCtrl]