'use strict';

/* App Module */

var bangman = angular.module('bangman', [
	'ngRoute',
	'bangmanControllers',
  	'bangmanServices'
]);

bangman.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: 'partials/test.html',
        controller: 'HangmanCtrl'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);