class exports.Game

	constructor: (@io) ->
		Hangman = require('./hangman').Hangman
		SimpleGenerator = require('./simplegenerator').SimpleGenerator
		simpleGenerator = new SimpleGenerator
		@hangman = new Hangman simpleGenerator.generate()

	check: (guess, player) ->
		@hangman.check guess, (match) ->
			player.emit('hangman', { phrase: match })

	start: () ->
		console.log "starting game"
		for socket in @io.clients()
        	@check [], socket
        	socket.emit('time', { time: 15 })
        setTimeout (game) ->
        	game.stop()
        	game.start()
        , 15000, @

	stop: () ->
		console.log "stopping game"
		for socket in @io.clients()
        	@check [], socket