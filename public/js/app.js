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
      when('/guess', {
        templateUrl: 'partials/guess',
        controller: 'GuessCtrl'
      }).
      when('/report', {
        templateUrl: 'partials/report',
        controller: 'ReportCtrl'
      }).
      when('/login', {
        templateUrl: 'login',
      }).
      otherwise({
        redirectTo: '/guess'
      });
  }]);

var landingpage = angular.module('landingpage', ['landingpageControllers']);
