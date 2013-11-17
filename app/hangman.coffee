class Hangman

	constructor: (@word) ->


	# replaces each occurrence of a guess in the seeked
	# word. in case a match has been found the guess is
	# consumed.
	check: (guesses, success, error) ->
		indicies = []
		for i in [0...guesses.length]
			index = match @word, guesses[i], indicies, (index)
			if (index == -1)
				continue
			indicies.push index
		indicies.sort (a,b) -> a - b
		
		guessedword = ''
		for i in [0...@word.length]
			if (@word[i] == ' ')
				guessedword += ' '
				continue
			if (indicies.filter (x) -> x == i).length > 0
				guessedword += @word[i]
			else
				guessedword += '_'
				
		success guessedword

	# TODO: check why word has to be passed and cannot be accessed by @word
	match = (word, letter, indicies) ->
		index = -1
		for i in [0...word.length]
			if letter != word[i]
				continue
			if (indicies.filter (x) -> x == i).length > 0
				# the letter has already been added
				continue
			# the letter is contained in the word and has not 
			# been added
			index = i
			break
		index

module.exports = Hangman

