class Hangman

	constructor: (@word) ->


	# replaces each occurrence of a guess in the seeked
	# word. in case a match has been found the guess is
	# consumed.
	check: (guesses) ->
		guessedword = ''
		found = 0
		for x in [0...@word.length]
			if @word[x] == ' '
				guessedword += ' '
				continue

			index = match @word[x], guesses[found...guesses.length]
			if index == -1
				guessedword += '_'
			else 
				# consume guess
				guessedword += guesses[found + index]
				found += 1

		guessedword

	match = (letter, guesses) ->
		index = -1
		for y in [0...guesses.length]
			if letter != guesses[y]
				continue
			index = y
		index




module.exports = Hangman

