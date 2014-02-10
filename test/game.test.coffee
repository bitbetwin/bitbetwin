Game = require "../app/models/game"
should = require "should"
GameDao = require "../app/dao/gamedao"
async = require "async"

restful = require 'node-restful'
mongoose = restful.mongoose

describe "Game", ->

  before (done)->
    mongoose.connect "mongodb://localhost/bitbetwinTest"
    db = mongoose.connection
    db.on 'error', done
    db.once 'open', done

  after (done)->
    Game.remove {}
    mongoose.connection.close()
    done()
    
  beforeEach (done)->
    Game.remove {}, done #empty database

  it "should create a game", (done) ->
    @game = new Game name: "testgame", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
    @game.save (err) ->
      Game.findOne name: "testgame", (err, game) ->
        throw err  if err
        game.name.should.be.equal "testgame"
        game.phrasegenerator.should.be.equal "singlephrasegenerator"
        game.durationcalculator.should.be.equal "simpledurationcalculator"
        done()  

  it "should return all games", (done) ->
    async.parallel [(callback) ->
      @game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save (err) ->
        callback err
    , (callback) ->
      @game = new Game name: "testgame2", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save (err) ->
        callback err
    ], (err) ->
      throw err  if err
      GameDao.retrieveGames (err, games) ->
        throw err if err
        games.length.should.be.equal 2
        done()