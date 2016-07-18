_ = require 'lodash'
path = require 'path'
require './model.coffee'

angular.module 'starter.controller', ['starter.model', 'ionic']
  .config ($stateProvider) ->
    $stateProvider.state 'app',
      abstract: true
      templateUrl: 'templates/menu.html'

    $stateProvider.state 'app.mount',
      cache: false
      url: '/vol'
      views:
        menuContent:
          templateUrl: 'templates/vol.html'
          controller: 'VolCtrl'
      resolve:
        resource: 'resource'
        me: (resource) ->
          resource.User.me().$fetch
            reset: true

  .controller 'VolCtrl', ($rootScope, $scope, resource) ->
    collection = []
    newExplorer = ->
      ret = new resource.Dir()
      ret.$fetch()
      collection.push ret
    newExplorer()
    $rootScope.$on 'newExplorer', newExplorer
    _.extend $scope, 
       collection: collection
       rmExplorer: (index) ->
         collection.splice index, 1

  .controller 'FileCtrl', ($scope, $ionicActionSheet, resource) ->
    _.extend $scope,
      path: path
      console: console
      url: ->
        if $scope.model.isFile
          "file/#{$scope.model.id}"
        else
          '#'
      open: ->
        if not $scope.model.isFile
          $scope.dir.chdir $scope.model
      select: ->
        hide = $ionicActionSheet.show
          buttons: [
              {text: 'Rename'}
              {text: 'Permission'}
            ]
          destructiveText: 'Delete'
          destructiveButtonClicked: ->
            $scope.model
              .$destroy()
              .then ->
                $scope.dir.child = _.filter $scope.dir.child, (file) ->
                  file.id != $scope.model.id
                hide() 
          buttonClicked: (index) ->
            switch index
              when 0
                $scope["form_#{$scope.model.id}"].$show()
                hide()
              when 1
                return
              else
                return
