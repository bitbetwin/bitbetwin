Game = require "../app/models/game"
should = require "should"
DataAccess = require "../app/dataaccess"

restful = require 'node-restful'
mongoose = restful.mongoose

describe "Game", ->

  before (done)->
    mongoose.connect "mongodb://localhost/bangmandbTest"
    db = mongoose.connection
    db.on 'error', done
    db.once 'open', done

  after (done)->
    mongoose.connection.close()
    done()
    
  beforeEach (done)->
    Game.remove {}, done #empty database

  it "should return all games", (done) ->
  	result = DataAccess.retrieveGames()
  	result.games.length.should.be.equal 2
  	done()