class exports.Game

	constructor: (@io, @name) ->
		SimpleGenerator = require('./simplegenerator').SimpleGenerator
		@simpleGenerator = new SimpleGenerator

	check: (player, guess) ->
		player.guess.push guess
		@hangman.check player.guess, (match) ->
			player.emit('hangman', { phrase: match })

	join: (player) ->
		console.log player.user.email + " joined " + @name
		player.join @name
		@broadcast player

	broadcast: (player) ->
		player.guess = []
		@check player, []
		player.emit 'time', { time: @countdown }

	start: () ->
		console.log "starting " + @name
		
		console.log "generating phrase"
		word = @simpleGenerator.generate()
		
		console.log "initialising " + @name
		Hangman = require('./hangman').Hangman
		@hangman = new Hangman word
		
		console.log "calculating game duration"
		@countdown = 15 #TODO: calculate game duration depending on the phrase difficulty
		
		console.log "broadcast game start"
		for socket in @io.clients @name
        	@broadcast socket	
        
        interval = setInterval (game) ->
        	game.countdown = game.countdown - 1
        , 1000, @
        
        setTimeout (game) ->
        	game.stop()
        	clearInterval interval
        	game.start()
        , @countdown * 1000, @

	stop: () ->
		console.log "stopping " + @name
		for socket in @io.clients @name
        	socket.guess.length = 0