class exports.Game

	constructor: (@io, @name) ->
		@io.log.info "initialising simplePhraseGenerator"
		SimplePhraseGenerator = require('./simplephrasegenerator').SimplePhraseGenerator
		SimpleDurationCalculator = require('./simpledurationcalculator').SimpleDurationCalculator
		@simplePhraseGenerator = new SimplePhraseGenerator
		@simpleDurationCalculator = new SimpleDurationCalculator

	check: (player, guess) ->
		@io.log.info player.user.email + " guessed " + guess
		player.game.guess.push guess
		that = @
		@hangman.check player.game.guess, (match) ->
			complete = (match == that.hangman.word)
			if (complete)
				@io.log.info player.user.email + " guessed the whole word correctly!"
				
			player.emit('hangman', {complete: complete, guesses: player.game.guess, time: that.countdown, phrase: match })

	join: (player) ->
		@io.log.info player.user.email + " joined " + @name
		player.join @name
		player.game = {}
		player.game.name = @name
		@broadcast player

	leave: (player) ->
		@io.log.info player.user.email + " left " + @name
		player.leave @name

	broadcast: (player) ->
		player.game.guess = []
		@check player, []

	start: () ->
		@io.log.info "starting " + @name
		
		@io.log.info "generating phrase"
		phrase = @simplePhraseGenerator.generate()
		
		@io.log.info "initialising " + @name
		Hangman = require('./hangman').Hangman
		@hangman = new Hangman phrase
		
		@io.log.info "calculating game duration"
		@countdown = @simpleDurationCalculator.calculate phrase
		
		@io.log.info "broadcast game start"
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
		@io.log.info "stopping " + @name
		for socket in @io.clients @name
			socket.game.guess.length = 0