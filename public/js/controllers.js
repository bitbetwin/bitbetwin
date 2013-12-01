'use strict';

/* Controllers */

var bangmanControllers = angular.module('bangmanControllers', []);
bangmanControllers.controller('HangmanCtrl', ['$scope', '$socket', function($scope, $socket) {
	$socket.on('hangman', function(hangman) {
		$scope.word = hangman.phrase;
	})

	$scope.guess = function() {
    	$socket.emit('guess', $scope.letter)
  	};
}]);