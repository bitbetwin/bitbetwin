restful = require 'node-restful'
mongoose = restful.mongoose

Game = require './models/game'
Credit = require './models/credit'
User = require './models/user'
Promise = require 'promise'

class DataAccess

  @init: (@io) ->
    GameEngine = require('./hangman/gameengine').GameEngine

    that = @
    @retrieveGames (err, games) ->
      throw err if err
      that.commands = new Array()
      for game in games
        engine = new GameEngine io, game
        that.commands[game.name] = new Array()
        that.commands[game.name]['instance'] = engine
        that.commands[game.name]['functions'] = ['join', 'leave', 'guess', 'report']
        engine.start()
      that.logger().info "initialised games"

    @loadConfig()

  @retrieveGames: (callback) ->
    Game.find {}, (err, games) ->
      callback err, games

    ####
    # TODO: extract to Credit DAO class
    ####

  @retrieveCredits: (userid, callback) ->
    Credit.find owner: userid, game: null, (err, credits) ->
      callback err, credits

  @drawCommission: (credit, callback) ->
    User.findOne email: "mail@bitbetwin.co", (err, bank) ->
      return callback err if err
      credit.game = null
      credit.owner = bank._id
      credit.save (err) ->
        callback err

  @chargeCredits: (userid, gameid, pot, commission, callback) ->
    bet = pot + commission
    if bet < 0
      callback "Too small bet"

    return callback() if bet == 0

    DataAccess.retrieveCredits userid, (err, credits) ->
      return callback err if err

      if credits.length < (pot + commission)
        return callback "Not enough credits"

      promises = []
      for credit in credits when credits.indexOf(credit) < pot
        credit.game = gameid
        promises.push credit.save (err) ->
          return callback err if err

      for credit in credits when credits.indexOf(credit) >= pot && credits.indexOf(credit) < (pot + commission)
        promises.push DataAccess.drawCommission credit, (err) ->
          return callback err if err

      Promise.all( promises ).then () ->
        console.log "finished charging"
        callback null

  @payWinners: (winners, gameid, callback) ->
    Credit.find game: gameid, (err, credits) ->
      return callback err if err

      if credits.length < winners.length
        return callback "Less credits than winners is not possible."

      share = Math.floor(credits.length / winners.length)

      promises = []

      # split credits by equal shares
      index = -1
      winnum = 0
      for winner in winners
        deal = 0
        while deal < share
          index = winnum + deal
          console.log credits[index]._id + ", index: " + index + " -> " + winner._id
          credits[index].owner = winner._id
          credits[index].game = null
          promises.push credits[index].save (err) ->
            throw err if err
          deal++
        winnum += share

      # handle remaining credits, which could not be split equally.
      # for now we just move them to the bank
      for credit in credits when credits.indexOf(credit) > index
          promises.push DataAccess.drawCommission credit, (err) ->
            throw err if err

      Promise.all( promises ).then () ->
        callback()

  @logger: () ->
    @io.log

  @loadConfig: () ->
    return @config if @config?
    
    #settings
    switch process.env.NODE_ENV
      when "development" 
        @env = "development"
      when "production"
        @env = "production"
      when "testing"
        @env = "testing" 
      else
        @env = "development"

    console.log @env + " mode started."

    @config = require("./config/config")[@env]

  @isInTestingMode: () ->
    return @env == 'testing'

  @isInDevMode: () ->
    return @env == 'testing' || @env == 'development'

  @startup: () ->
    console.log "connecting to " + @loadConfig().db_address
    mongoose.connect @loadConfig().db_address, (error) ->
      console.log "could not connect because: " + error if error
    db = mongoose.connection

    db.on 'error', console.error.bind(console, 'Mongo DB connection error:')

    db.once 'open', (callback) ->
      console.log "connected with mongodb"

  @shutdown: () ->
      mongoose.disconnect()

module.exports = DataAccess