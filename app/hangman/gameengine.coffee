DataAccess = require '../dataaccess'
SimpleDurationCalculator = require('./simpledurationcalculator').SimpleDurationCalculator
SinglePhraseGenerator = require('./phrasegenerator/singlephrasegenerator').SinglePhraseGenerator
SimplePhraseGenerator = require('./phrasegenerator/simplephrasegenerator').SimplePhraseGenerator

class exports.GameEngine

  constructor: (@io, @game) ->
    @io.log.info "initialising phraseGenerator"
    @started = false

    switch @game.durationcalculator
      when "durationcalculator" then @durationCalculator = new SimpleDurationCalculator
      else @durationCalculator = new SimpleDurationCalculator

    switch @game.phrasegenerator
      when "singlephrasegenerator" then @phraseGenerator = new SinglePhraseGenerator
      when "simplephrasegenerator" then @phraseGenerator = new SimplePhraseGenerator
      else @phraseGenerator = new SinglePhraseGenerator

    @reporttime = 10

  guess: (player, guess) ->
    @io.log.info player.user.email + " guessed " + guess
    player.game.guess.push guess

    that = @
    @hangman.check player.game.guess.join(""), (match) ->
      complete = (match == that.hangman.word)
      player.emit('hangman', {complete: complete, guesses: player.game.guess, time: that.countdown, phrase: match })

      # TODO: introduce caching for credit amount
      DataAccess.retrieveCredits player.user._id, (err, credits) ->
        amount = 0
        console.log credits
        for credit in credits
          amount += credit.value
        player.emit "credit", amount

      if (complete)
        that.io.log.info player.user.email + " guessed the whole word correctly!"

  join: (player) ->
    @io.log.info player.user.email + " joined " + @game.name
    player.join @game.name
    player.game = {}
    player.game.name = @game.name
    if @started
      @broadcast player
    else
      player.game.guess = []
      player.emit "stop"

  leave: (player, feed, callback) ->
    @io.log.info player.user.email + " left " + @game.name
    player.leave @game.name
    DataAccess.retrieveGames (err, games) ->
      callback games

  broadcast: (player) ->
    player.game.guess = []
    @guess player, ""

  start: () ->
    @io.log.info "starting " + @game.name
    @started = true
    @reporttime = 10

    @io.log.info "generating phrase"
    phrase = @phraseGenerator.generate()
    
    @io.log.info "initialising " + @game.name
    Hangman = require('./hangman').Hangman
    @hangman = new Hangman phrase
    
    @io.log.info "calculating game duration"
    @countdown = @durationCalculator.calculate phrase
    
    @io.log.info "broadcast game start"
    for socket in @io.clients @game.name
      socket.emit 'start'
      @broadcast socket

    starttime = new Date().getTime()
    interval = setInterval (engine) ->
      intervaltime = new Date().getTime()
      time = intervaltime - starttime
      engine.countdown = Math.round(engine.countdown - ( time / 1000 ))
      starttime = intervaltime
    , 1000, @

    setTimeout (engine) ->
      engine.stop()
      engine.started = false
      clearInterval interval
      interval = setInterval (engine) ->
        engine.reporttime = engine.reporttime - 1
      , 1000, engine
      setTimeout (engine) ->
        clearInterval interval
        engine.start() 
      , engine.reporttime * 1000, engine
    , @countdown * 1000, @

  stop: () ->
    @io.log.info "stopping " + @game.name
    @countdown = 0
    for socket in @io.clients @game.name
      socket.game.guess.length = 0
      socket.emit 'stop'

  report: (player, feed, callback) ->
    @io.log.info "sending report to " + player.user.email + "; time: " + (@countdown + @reporttime)
    callback {'time': @countdown + @reporttime }