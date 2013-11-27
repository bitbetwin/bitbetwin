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
        templateUrl: 'partials/guess.html',
        controller: 'HangmanCtrl'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);

var landingpage = angular.module('landingpage', [])
  .controller('LandingpageCtrl', function($scope) {
    $scope.signup = function() {
      $scope.message = 'Thanks for signing up! You will receive an invitation at ' + $scope.email + '.';
    }
  });