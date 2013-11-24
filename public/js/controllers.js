'use strict';

/* Controllers */

var bangmanControllers = angular.module('bangmanControllers', []);

bangmanControllers.controller('HangmanCtrl', ['$scope', function($scope) {
	$scope.word = 'test';
}]);