class exports.Game

	constructor: (@io, @name) ->
		console.log "initialising simplePhraseGenerator"
		SimplePhraseGenerator = require('./simplephrasegenerator').SimplePhraseGenerator
		SimpleDurationCalculator = require('./simpledurationcalculator').SimpleDurationCalculator
		@simplePhraseGenerator = new SimplePhraseGenerator
		@simpleDurationCalculator = new SimpleDurationCalculator

	check: (player, guess) ->
		player.game.guess.push guess
		that = @
		@hangman.check player.game.guess, (match) ->
			player.emit('hangman', { guesses: player.game.guess, time: that.countdown, phrase: match })

	join: (player) ->
		console.log player.user.email + " joined " + @name
		player.join @name
		player.game = {}
		player.game.name = @name
		@broadcast player

	leave: (player) ->
		console.log player.user.email + " left " + @name
		player.leave @name

	broadcast: (player) ->
		player.game.guess = []
		@check player, []

	start: () ->
		console.log "starting " + @name
		
		console.log "generating phrase"
		phrase = @simplePhraseGenerator.generate()
		
		console.log "initialising " + @name
		Hangman = require('./hangman').Hangman
		@hangman = new Hangman phrase
		
		console.log "calculating game duration"
		@countdown = @simpleDurationCalculator.calculate phrase
		
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
			socket.game.guess.length = 0