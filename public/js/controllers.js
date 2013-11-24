'use strict';

/* Controllers */

var bangmanControllers = angular.module('bangmanControllers', []);
bangmanControllers.controller('HangmanCtrl', ['$scope', 'socket', function($scope, socket) {
	socket.on('news', function(data) {
		$scope.word = data.hello;
	})
}]);