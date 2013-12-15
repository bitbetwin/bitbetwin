class exports.Game

	constructor: (@io) ->
		Hangman = require('./hangman').Hangman
		SimpleGenerator = require('./simplegenerator').SimpleGenerator
		simpleGenerator = new SimpleGenerator
		@hangman = new Hangman simpleGenerator.generate()

	check: (guess, player) ->
		@hangman.check guess, (match) ->
			player.emit('hangman', { phrase: match })

	join: (player) ->
		@hangman.check [], (match) ->
			player.emit('hangman', { phrase: match })

	start: () ->
		console.log "starting game"
		for socket in @io.clients()
        	@check [], socket

	end: () ->
		console.log "ending game"
		for socket in @io.clients()
        	@check [], socket

	init: () ->
		console.log "initialisation"
		@start()
		setTimeout (game) -> 
			game.end()
			game.start()
		, 5000, @