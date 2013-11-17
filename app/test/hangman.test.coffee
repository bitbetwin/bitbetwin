Hangman = require '../hangman'

exports.HangmanTest =

	setUp: (callback) ->
		@complete = 'guess word test'
		@empty = '_____ ____ ____'
		@hangman = new Hangman @complete
		callback()

	'test check guess with multiple matches': (test) ->
		guessedword = @hangman.check 'guess'
		test.equal 'guess ____ ____', guessedword
		test.done()

	'test check guess without match': (test) ->
		guessedword = @hangman.check 'axyz1389?'
		test.equal @empty, guessedword
		test.done()

	'test check guess in divers orders': (test) ->
		guessedword = @hangman.check 'seuotss'
		test.equal '_uess _o__ t_s_', guessedword
		test.done()

	'test check guess with complete match': (test) ->
		guessedword = @hangman.check 'seuotssgrdwte'
		test.equal @complete, guessedword
		test.done()