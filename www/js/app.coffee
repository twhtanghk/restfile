module = angular.module('starter', ['ionic', 'starter.controller', 'http-auth-interceptor'])

module.run ($ionicPlatform, $location, $http, authService) ->
	$ionicPlatform.ready ->
		if (window.cordova && window.cordova.plugins.Keyboard)
			cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
		if (window.StatusBar)
			StatusBar.styleDefault()
		
	# set authorization header once browser authentication completed
	if $location.url().match /access_token/
			data = $.deparam $location.url().split("/")[1]
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
		
module.config ($stateProvider, $urlRouterProvider) ->
	$stateProvider.state 'app',
		url: "/file"
		abstract: true
		controller: 'AppCtrl'
		templateUrl: "templates/menu.html"
		
	$stateProvider.state 'app.search',
		url: "/search"
		views:
			'menuContent':
				templateUrl: "templates/search.html"

	$stateProvider.state 'app.list',
		url: "/list/*path"
		controller: 'FileCtrl'
		views:
			'menuContent':
				templateUrl: "templates/list.html"
		
	$urlRouterProvider.otherwise('/file/list/')