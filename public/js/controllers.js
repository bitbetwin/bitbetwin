'use strict';

/* Controllers */

var loggedIn = false;
var started = false;
var complete = false;

var bangmanControllers = angular.module('bangmanControllers', []);
bangmanControllers.controller('GuessCtrl', ['$scope', '$socket', '$timeout', '$log', '$location', 
  function($scope, $socket, $timeout, $log, $location) {

    var countdown;
  	$socket.on('hangman', function(hangman) {
      $log.info('hangman');
      started = true;
      $log.info(hangman.phrase);
      $log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
  		$scope.word = hangman.phrase;
      $scope.guesses = hangman.guesses;
      $scope.time = hangman.time;
      $scope.duration = hangman.duration;
      complete = hangman.complete;
      if (complete) {
        $log.info('complete');
        $location.path('/report');
      }

      $scope.onTimeout = function() {
        $scope.time--;
        if ($scope.time <= 0) {
          $log.info($scope.time);
          $log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
        } else {
          countdown = $timeout($scope.onTimeout,1000);
        }
      }
      countdown = $timeout($scope.onTimeout,1000);
  	});

    $socket.on('loggedin', function(games) {
        loggedIn = true;
        complete = false;
        $scope.games = games;
    });

    $socket.on('stop', function() {
        $log.info('incomplete');
        $location.path('/report'); 
    });

    $scope.guess = function() {
      sendGuess(this.letter);
      this.letter = '';
    };

    $scope.leave = function() {
      $socket.emit('leave', '', function(games) {
        $log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
        $scope.time = '';
        started = false;
        $scope.games = games;
      });
    };

    $scope.join = function(game) {
      $log.info('joining ' + game);
      $socket.emit('join', game);
    };

    $scope.loggedIn = function() {
      return loggedIn;
    };

    $scope.started = function() {
      return started;
    };

    $scope.handleKey = function(key) {
        if (key.keyCode == '13') {
          $log.info('got enter!');
          sendGuess(this.letter);
          this.letter = '';
        } else {
          var sign = String.fromCharCode(key.keyCode);
          if (typeof(this.letter) != 'undefined') {
            this.letter = this.letter + sign;
          } else {
            this.letter = sign;
          }
        }
        key.preventDefault();
    };

    function sendGuess(letter) {
      if (typeof(letter) != 'undefined' && letter.length > 0) {
        $log.info('guessing ' + letter);
        $socket.emit('guess', letter);
      }
    }
}]);


bangmanControllers.controller('MainCtrl', ['$scope', '$socket', '$log',
  function($scope, $socket, $log) {

    $socket.on('wallet', function(wallet) {
      $log.warn("credits: " + wallet.credits);
      $scope.credits = wallet.credits;
    })

    $socket.on('validation', function(validation) {
      $log.warn(validation.warning);
      $scope.warning = validation.warning;
    });
}]);


bangmanControllers.controller('ReportCtrl', ['$scope', '$socket', '$log', '$location', '$timeout',
  function($scope, $socket, $log, $location, $timeout) {

    $socket.on('start', function() {
      $location.path('/guess');
    });

    var countdown;

    $scope.$on('$routeChangeSuccess', function(next, current) { 
      $log.info('init report!');
      $socket.emit('report', '', function(data) {
      $log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
      $scope.time = data.time;
      $scope.onTimeout = function() {
          $scope.time--;
          if ($scope.time <= 0) {
            $log.info('timeout was successfully canceled: ' + $timeout.cancel(countdown));
          } else {
            countdown = $timeout($scope.onTimeout,1000);
          }
        }
        countdown = $timeout($scope.onTimeout,1000);
      });
    });

    $scope.loggedIn = function() {
      return loggedIn;
    };

    $scope.complete = function() {
      return complete;
    };
}]);

var landingpageControllers = angular.module('landingpageControllers', []);
landingpageControllers.controller('LandingpageCtrl', function($scope, $http) {
	$scope.subscribe = function() {
		$http.put('/subscribe', {name: $scope.name, email: $scope.email, newsletter: $scope.newsletter}).success(function (data, status) {
		 	$scope.response = data;
      if (!data.err) {
        $scope.subscribe_form.$setPristine();
        $scope.name = '';
        $scope.email = '';
        $scope.newsletter = false;
      }
		});
	}
});