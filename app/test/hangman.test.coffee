Hangman = require '../hangman'

exports.HangmanTest =

	setUp: (callback) ->
		@hangman = new Hangman 'guess word test'
		callback()

	'test check guess without': (test) ->
		guessedword = @hangman.check 'guess'
		test.equal 'guess ____ ____', guessedword
		test.done()