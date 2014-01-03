DataAccess = require '../dataaccess'

class exports.Game

	constructor: (@io, @name) ->
		@io.log.info "initialising phraseGenerator"
		SimpleDurationCalculator = require('./simpledurationcalculator').SimpleDurationCalculator
		
		if DataAccess.isInTestingMode()
			SinglePhraseGenerator = require('./phrasegenerator/singlephrasegenerator').SinglePhraseGenerator
			@phraseGenerator = new SinglePhraseGenerator
		else
			SimplePhraseGenerator = require('./phrasegenerator/simplephrasegenerator').SimplePhraseGenerator 
			@phraseGenerator = new SimplePhraseGenerator

		@simpleDurationCalculator = new SimpleDurationCalculator

	guess: (player, guess) ->
		@io.log.info player.user.email + " guessed " + guess
		player.game.guess.push guess
		that = @
		@hangman.check player.game.guess, (match) ->
			complete = (match == that.hangman.word)
			player.emit('hangman', {complete: complete, guesses: player.game.guess, time: that.countdown, phrase: match })
			if (complete)
				that.io.log.info player.user.email + " guessed the whole word correctly!"

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
		@guess player, ""

	start: () ->
		@io.log.info "starting " + @name
		
		@io.log.info "generating phrase"
		phrase = @phraseGenerator.generate()
		
		@io.log.info "initialising " + @name
		Hangman = require('./hangman').Hangman
		@hangman = new Hangman phrase
		
		@io.log.info "calculating game duration"
		@countdown = @simpleDurationCalculator.calculate phrase
		
		@io.log.info "broadcast game start"
		for socket in @io.clients @name
			socket.emit 'start'
			@broadcast socket

		interval = setInterval (game) ->
			game.countdown = game.countdown - 1
		, 1000, @

		setTimeout (game) ->
			game.stop()
			clearInterval interval
			setTimeout (game) ->
				game.start() 
			, 10 * 1000, game
		, @countdown * 1000, @

	stop: () ->
		@io.log.info "stopping " + @name
		for socket in @io.clients @name
			socket.game.guess.length = 0
			socket.emit 'stop'

	report: (player) ->
		@io.log.info "sending report to " + player.user.email
		player.emit 'report', {'time': 10 + @countdown - 1 }