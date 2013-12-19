class exports.Game

	constructor: (@io, @name) ->
		SimpleGenerator = require('./simplegenerator').SimpleGenerator
		@simpleGenerator = new SimpleGenerator

	check: (guess, player) ->
		player.guess.push guess
		@hangman.check player.guess, (match) ->
			player.emit('hangman', { phrase: match })

	join: (player) ->
		console.log player.user.email + " is joining game1"
		player.join(@name)
		@check [], player
		player.emit 'time', { time: @countdown }

	start: () ->
		console.log "starting game"
		
		console.log "generating phrase"
		word = @simpleGenerator.generate()
		
		console.log "initialising game"
		Hangman = require('./hangman').Hangman
		@hangman = new Hangman word
		
		console.log "calculating game duration"
		@countdown = 15 #TODO: calculate game duration depending on the phrase difficulty
		
		console.log "broadcast game start"
		for socket in @io.clients(@name)
        	@check [], socket
        	socket.guess = []
        	socket.emit 'time', { time: @countdown }
        
        interval = setInterval (game) ->
        	game.countdown = game.countdown - 1
        , 1000, @
        
        setTimeout (game) ->
        	game.stop()
        	clearInterval interval
        	game.start()
        , @countdown * 1000, @

	stop: () ->
		console.log "stopping game"
		for socket in @io.clients(@name)
        	socket.guess.length = 0
        	@check [], socket