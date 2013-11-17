class GuessedWord

	constructor: (@word) ->
		for i in [0...@word.length]
			if @word[i] == ' '
				guessedWord += ' '
			else 
				guessedWord += '_'
		guessedWord


module.exports = GuessedWord