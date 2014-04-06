should = require "should"
GameDao = require "../app/dao/gamedao"
async = require "async"

DataAccess = require "../app/dataaccess"

describe "Game", ->

  before (done)->
    process.env.NODE_ENV = "testing"
    DataAccess.startup (err, @db) =>
      throw err if err
      @db.Game.destroy()
      done()

  it "should create a game", (done) ->
    @game = DataAccess.db.Game.build name: "testgame", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
    @game.save().complete (err, game) ->
      DataAccess.db.Game.find( where: name: "testgame").complete (err, game) ->
        throw err if err

        game.name.should.be.equal "testgame"
        game.phrasegenerator.should.be.equal "singlephrasegenerator"
        game.durationcalculator.should.be.equal "simpledurationcalculator"
        done()  

  it "should return all games", (done) ->
    async.parallel [(callback) =>
      console.log "step1"
      @game = DataAccess.db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"
      @game.save().complete (err, game) ->
        callback err
    , (callback) =>
      console.log "step2"
      @game = DataAccess.db.Game.build name: "testgame2", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save().complete (err, game) ->
        callback err
    ], (err) =>
      console.log "step3"
      throw err if err
      GameDao.retrieveGames (err, games) ->
        console.log "step4"
        throw err if err
        games.length.should.be.equal 3
        done()