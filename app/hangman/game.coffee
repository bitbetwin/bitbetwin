class exports.Game

	constructor: () ->
		Hangman = require('./hangman').Hangman
		SimpleGenerator = require('./simplegenerator').SimpleGenerator
		simpleGenerator = new SimpleGenerator
		@hangman = new Hangman simpleGenerator.generate()

	check: (guess, player) ->
		@hangman.check guess, (match) ->
			console.log "sending" + match
			player.emit('hangman', { phrase: match })

	start: () ->
		console.log "starting game"

	end: () ->
		console.log "ending game"

	init: () ->
		console.log "initialisation"
		@start()
		setTimeout (game) -> 
			game.end()
			game.start()
		, 5000, @