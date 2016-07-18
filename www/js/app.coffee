require './controller.coffee'
require 'angular-xeditable'
window.jQuery = require 'jquery'
require 'bootstrap'

angular.module 'starter', ['ionic', 'starter.controller', 'xeditable']
  .config ($urlRouterProvider) ->
    $urlRouterProvider.otherwise '/vol'

  .run ($rootScope, $log) ->
    $rootScope.$on '$stateChangeError', (evt, toState, toParams, fromState, formParams, err) ->
      $log.error err

  .run (editableOptions) ->
    editableOptions.theme = 'bs3'
