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
        templateUrl: 'guess',
        controller: 'HangmanCtrl'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);

var landingpage = angular.module('landingpage', ['landingpageControllers']);
