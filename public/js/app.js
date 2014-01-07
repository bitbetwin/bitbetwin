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

bangman.directive('keyListener', [
  '$document',
  '$rootScope',
  function($document, $rootScope) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        var keypress = function(e) {
          scope.$apply(function() {
              listener.call(scope, event);
          });
        }
        var listener = scope.$eval(attrs.keyListener);
        $document.bind('keypress', keypress);
        scope.$on('$destroy', function() {
          console.log('unregister keypress');
          $document.unbind('keypress', keypress);
        })
      }
    };
  }
]);

var landingpage = angular.module('landingpage', ['landingpageControllers']);
