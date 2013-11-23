'use strict';

/* Controllers */

var bangman = angular.module('bangman', []);

bangman.controller('HangmanCtrl', function($scope) {
	$scope.word = 'test';
});