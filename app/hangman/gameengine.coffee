DataAccess = require '../dataaccess'
CreditDao = require '../dao/creditdao'
GameDao = require '../dao/gamedao'

Promise = require 'promise'

class exports.GameEngine

  constructor: (@io, @game) ->
    @io.log.info "initialising phraseGenerator"
    @started = false
    SimpleDurationCalculator = require('./simpledurationcalculator').SimpleDurationCalculator
    SimpleChargeCalculator = require('./simplechargecalculator').SimpleChargeCalculator
    
    if DataAccess.isInTestingMode()
      SinglePhraseGenerator = require('./phrasegenerator/singlephrasegenerator').SinglePhraseGenerator
      @phraseGenerator = new SinglePhraseGenerator
    else
      SimplePhraseGenerator = require('./phrasegenerator/simplephrasegenerator').SimplePhraseGenerator 
      @phraseGenerator = new SimplePhraseGenerator

    @simpleDurationCalculator = new SimpleDurationCalculator
    @simpleChargeCalculator = new SimpleChargeCalculator
    @reporttime = 10

  guess: (player, guess) ->
    pot = @simpleChargeCalculator.pot guess
    commission = @simpleChargeCalculator.commission guess

    @io.log.info "charging " + commission + " credit from " + player.user.email + " to bank: mail@bitbetwin.co"
    @io.log.info "charging " + pot + " credit from " + player.user.email + " to " + @game.name
    logger = @io.log

    that = @
    CreditDao.chargeCredits player.user._id, @game._id, pot, commission, (err) ->
      return player.emit('validation', { warning: err }) if err

      logger.info player.user.email + " guessed " + guess
      player.game.guess.push guess

      player.user.credits -= (pot + commission)
      
      that.hangman.check player.game.guess.join(""), (match) ->
        complete = (match == that.hangman.word)
        socket.emit('hangman', { complete: complete, guesses: player.game.guess, duration: that.duration, time: that.countdown, phrase: match }) for socket in player.user.sockets
        socket.emit('wallet', { credits: player.user.credits }) for socket in player.user.sockets
        
        if complete
          player.game.complete = true
          logger.info player.user.email + " guessed the whole word correctly!"

        that.stats()

  stats: () ->
    winners = 0
    for player in @io.clients(@game.name)
      if player.game.complete
        winners++

    that = @
    players = @io.clients(@game.name).length
    CreditDao.retrievePot @game._id, (err, credits) ->
      that.broadcast (player) ->
        player.emit 'stats', { players: players, pot: credits.length, winners: winners }

  join: (player) ->
    @io.log.info player.user.email + " joined " + @game.name
    player.join @game.name
    player.game = {}
    player.game.name = @game.name
    if @started
      player.game.guess = []
      @guess player, ""
    else
      player.game.guess = []
      player.emit "stop"

  leave: (player, feed, callback) ->
    @io.log.info player.user.email + " left " + @game.name
    player.leave @game.name
    @stats()
    GameDao.retrieveGames (err, games) ->
      callback games

  broadcast: (fx) ->
    for player in @io.clients @game.name
      fx player

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
    @duration = @countdown = @simpleDurationCalculator.calculate phrase
    
    @io.log.info "broadcast game start"
    that = @
    @broadcast (player) ->
      player.emit 'start'
      player.game.guess = []
      player.game.complete = false
      that.guess player, ""

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

    if @io.clients(@game.name).length < 1
      return

    winners = []
    for player in @io.clients @game.name
      if player.game.complete
        winners.push player.user
      player.game.guess.length = 0
      player.emit 'stop'

    that = @
    logger = @io.log
    CreditDao.payWinners winners, @game._id, (err, share) ->
      logger.warn if err
      
      console.log winners
      for winner in winners
        winner.credits += share 

      for socket in that.io.clients that.game.name
        socket.emit('wallet', { credits: socket.user.credits }) 


  report: (player, feed, callback) ->
    @io.log.info "sending report to " + player.user.email + "; time: " + (@countdown + @reporttime)
    @stats()
    callback {'time': @countdown + @reporttime }