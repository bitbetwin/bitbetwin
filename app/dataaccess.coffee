restful = require 'node-restful'
mongoose = restful.mongoose

Game = require './models/game'
Credit = require './models/credit'

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

  @retrieveCredits: (userid, callback) ->
    Credit.find owner: userid, (err, credits) ->
      callback err, credits

  @chargeCredits: (userid, gameid, amount, callback) ->
    Credit.find owner: userid, game: { $exists: false }, (err, credits) ->
      callback err if err
      if credits.length == 0
        return callback "Not enough credits"
      values = 0
      for credit in credits
        values += credit.value
      if values < amount
        return callback "Not enough credits"

      #todo knapsack problem for choosing the best fitting credits
      i = 0
      while i < amount
        credits[i].game = gameid
        credits[i].save (err) ->
          return callback err if err
        i++

      callback null

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