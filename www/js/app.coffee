module = angular.module('starter', ['ionic', 'starter.controller'])

module.run ($ionicPlatform) ->
	$ionicPlatform.ready ->
		if (window.cordova && window.cordova.plugins.Keyboard)
			cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
		if (window.StatusBar)
			StatusBar.styleDefault()
	
module.config ($stateProvider, $urlRouterProvider, $httpProvider) ->
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