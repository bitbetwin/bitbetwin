'use strict';

/* Controllers */

var bangmanControllers = angular.module('bangmanControllers', []);
bangmanControllers.controller('HangmanCtrl', ['$scope', '$socket', '$timeout', function($scope, $socket, $timeout) {
	$socket.on('hangman', function(hangman) {
		$scope.word = hangman.phrase;
	});
    $socket.on('loggedin', function(variables) {
        $scope.username=variables.username;
    });
    var countdown;
    $socket.on('time', function(data) {
    	$timeout.cancel(countdown);
    	$scope.time = data.time;
	    $scope.onTimeout = function() {
	        $scope.time--;
    		if ($scope.time <= 0) {
    			 $timeout.cancel(countdown);
    		} 
	        countdown = $timeout($scope.onTimeout,1000);
	    }
	    countdown = $timeout($scope.onTimeout,1000);
    });

	$scope.guess = function() {
    	$socket.emit('guess', this.letter);
  	};

  	$scope.loggedIn = function() {
  		return typeof this.username !== 'undefined';
  	};
}]);

var landingpageControllers = angular.module('landingpageControllers', []);
landingpageControllers.controller('LandingpageCtrl', function($scope, $http) {
	$scope.signup = function() {
	  //$scope.message = 'Thanks for signing up! You will receive an invitation at ' + $scope.email + '.';
		$http.put('/subscribe/' + $scope.email, {name: $scope.name, email: $scope.email}).success(function (data, status) {
		 	$scope.response = data;
		});
	}
});