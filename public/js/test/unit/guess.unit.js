'use strict';
 
describe('HangmanCtrl', function(){
    var scope, socket;

    beforeEach(angular.mock.module('bangman'));
    
    beforeEach(angular.mock.inject(function($rootScope, $controller, _$socket_){
        
        scope = $rootScope.$new();
        socket = _$socket_;

        $controller('HangmanCtrl', {$scope: scope, $socket: socket});
    }));

    // tests start here
    it('word should be initialised empty', function(){
        var match = 'empty string';
        socket.emit('hangman', { phrase: match })
        socket.on('hangman', function() {
            expect(scope.word).toBe(match);
        });
    });
    
});