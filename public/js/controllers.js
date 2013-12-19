'use strict';

/* Controllers */

var loggedIn = false;

var bangmanControllers = angular.module('bangmanControllers', []);
bangmanControllers.controller('HangmanCtrl', ['$scope', '$socket', '$timeout', '$log', 
  function($scope, $socket, $timeout, $log) {

  	$socket.on('hangman', function(hangman) {
      $log.info(hangman.phrase);
  		$scope.word = hangman.phrase;
  	});

    $socket.on('loggedin', function(variables) {
        loggedIn = true;
        $log.info(loggedIn);
        $scope.username = variables.username;
        $scope.games = variables.games;
    });

    var countdown;
    $socket.on('time', function(data) {
    	$log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
    	$scope.time = data.time;
	    $scope.onTimeout = function() {
        $scope.time--;
    		if ($scope.time <= 0) {
          $log.info($scope.time)
          $log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
    		} else {
          countdown = $timeout($scope.onTimeout,1000);
        }
	    }
	    countdown = $timeout($scope.onTimeout,1000);
    });

    $scope.guess = function() {
    	$socket.emit('guess', this.letter);
      this.letter = '';
  	};

    $scope.join = function(game) {
      $log.info('joining ' + game);
      $socket.emit('join', game);
    }

  	$scope.loggedIn = function() {
      $log.info(loggedIn);
      return loggedIn;
  	};

    $scope.started = function() {
      return typeof this.time !== 'undefined'
    }
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