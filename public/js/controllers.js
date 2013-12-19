'use strict';

/* Controllers */

var loggedIn = false;
var started = false;

var bangmanControllers = angular.module('bangmanControllers', []);
bangmanControllers.controller('HangmanCtrl', ['$scope', '$socket', '$timeout', '$log', 
  function($scope, $socket, $timeout, $log) {

    var countdown;
  	$socket.on('hangman', function(hangman) {
      $log.info('hangman');
      started = true;
      $log.info(hangman.phrase);
      $log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
  		$scope.word = hangman.phrase;
      $scope.time = hangman.time;
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

    $socket.on('loggedin', function(variables) {
        loggedIn = true;
        $log.info(loggedIn);
        $scope.username = variables.username;
        $scope.games = variables.games;
    });

    $scope.guess = function() {
      $log.info('guessing ' + this.letter);
    	$socket.emit('guess', this.letter);
      this.letter = '';
  	};

    $scope.leave = function() {
      started = false;
      $log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
      $scope.time = '';
      $socket.emit('leave');
    }

    $scope.join = function(game) {
      $log.info('joining ' + game);
      $socket.emit('join', game);
    }

  	$scope.loggedIn = function() {
      return loggedIn;
  	};

    $scope.started = function() {
      return started;
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