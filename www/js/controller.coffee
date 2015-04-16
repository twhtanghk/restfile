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
			
		home: ->
			$location.url("file/file/")
		
		cd: (folder = null) ->
			if _.isEmpty folder or _.isNull folder or _.isUndefined folder
				model.User.me()
					.then (user) =>
						@model.path = "#{user.username}/"
						@loadMore()
					.catch alert
			else
				@model.path = folder
				@loadMore()
			
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
			return @
		
		# update properties of specified file
		edit: ->
			$ionicModal.fromTemplateUrl('templates/file/edit.html', scope: $scope).then (modal) =>
				$scope.model.newname = $scope.model.name
				$scope.modal = modal
				$scope.modal.show()
				
		remove: (file) ->
			@model.remove(file)
			
		upload: (files) ->
			_.each files, (local) =>
				remote = (_.findWhere @model.models, name: local.name) || new model.File path: "#{@model.path}#{local.name}"
				remote.$save {file: local}
					.then =>
						@model.add remote
					.catch alert

	if _.isUndefined $scope.model
		$scope.model = new model.File path: $stateParams.path
		$scope.model.$fetch()
	$scope.controller = new FileView(model: $scope.model)
		
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

SelectCtrl = ($scope, $ionicModal) ->
	class SelectView
		select: (@name, @model, @collection) ->
			$ionicModal.fromTemplateUrl('templates/permission/select.html', scope: $scope).then (modal) =>
				@modal = modal
				@modal.show()
				
		ok: ->
			$scope.$emit @name, @model 
			@modal.remove()
			
		cancel: ->
			_.extend @model, @model.previousAttributes
			@modal.remove()
			
	$scope.controller = new SelectView()
	
MultiSelectCtrl = ($scope, $ionicModal) ->
	class MultiSelectView
		# model: array of selected values
		select: (@name, @model, @collection) ->
			$ionicModal.fromTemplateUrl('templates/permission/multiselect.html', scope: $scope).then (modal) =>
				@modal = modal
				@modal.show()
		
		selected: (value) ->
			_.contains @model, value
			
		ok: ->
			@model = _.map $(@modal.$el).find('input:checked'), (el) ->
				el.name
			$scope.$emit @name, @model
			@modal.remove()
			
		cancel: ->
			_.extend @model, @model.previousAttributes
			@modal.remove()
			
	$scope.controller = new MultiSelectView()
	
PermissionCtrl = ($rootScope, $scope, $ionicModal, model) ->
	class PermissionView
		modelEvents:
			userGrp:	'update'
			fileGrp:	'update'
			action:		'update'
		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
			
		update: (event, value) =>
			@model[event.name] = value
			
		save: ->
			@model.$save().catch alert
										
	$scope.controller = new PermissionView model: $scope.model
		
AclCtrl = ($rootScope, $scope, model) ->
	class AclView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
			
			$scope.userGrps = new model.UserGrps()
			$scope.userGrps.$fetch()
			
			$scope.fileGrps = new model.FileGrps()
			$scope.fileGrps.$fetch()
			
			$scope.actions = new model.Collection(['read', 'write'])
				
		loadMore: ->
			@collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
				
		add: ->
			@collection.add new model.Permission
				userGrp:	''
				fileGrp:	''
				action:		[]
				
		remove: (perm) ->
			@collection.remove perm
	
	$scope.collection = new model.Acl()
	$scope.collection.$fetch()
	$scope.controller = new AclView collection: $scope.collection 
	
config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$rootScope', '$scope', '$http', 'platform', 'authService', 'model', AppCtrl]
angular.module('starter.controller').controller 'MenuCtrl', ['$rootScope', '$scope', MenuCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$rootScope', '$scope', '$stateParams', '$location', '$ionicModal', 'model', FileCtrl]
angular.module('starter.controller').controller 'PermissionCtrl', ['$rootScope', '$scope', '$ionicModal', 'model', PermissionCtrl]
angular.module('starter.controller').controller 'AclCtrl', ['$rootScope', '$scope', 'model', AclCtrl]
angular.module('starter.controller').controller 'SelectCtrl', ['$scope', '$ionicModal', SelectCtrl]
angular.module('starter.controller').controller 'MultiSelectCtrl', ['$scope', '$ionicModal', MultiSelectCtrl]