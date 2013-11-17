Hangman = require '../hangman'

exports.HangmanTest =

	setUp: (callback) ->
		@hangman = new Hangman 'guess word test'
		callback()

	'test check guess with multiple matches': (test) ->
		@hangman.check 'guess', (guessedword) ->
			test.equal 'guess ____ ____', guessedword
			test.done()

	'test check guess without match': (test) ->
		@hangman.check 'axyz1389?', (guessedword) ->
			test.equal '_____ ____ ____', guessedword
			test.done()

	'test check guess in divers orders': (test) ->
		@hangman.check 'seuotss', (guessedword) ->
			test.equal '_uess _o__ t_s_', guessedword
			test.done()

	'test check guess with complete match': (test) ->
		@hangman.check 'seuotssgrdwte', (guessedword) ->
			test.equal 'guess word test', guessedword
			test.done()