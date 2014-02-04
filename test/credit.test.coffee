Credit = require "../app/models/credit"
User = require "../app/models/user"
Game = require "../app/models/game"

should = require "should"
DataAccess = require "../app/dataaccess"
async = require "async"

restful = require 'node-restful'
mongoose = restful.mongoose

describe "Credit", ->

  before (done)->
    mongoose.connect "mongodb://localhost/bitbetwinTest"
    db = mongoose.connection
    db.on 'error', done
    db.once 'open', done

  after (done)->
    mongoose.connection.close()
    done()
    
  beforeEach (done) ->
    #empty database
    async.parallel [(callback) ->
        Game.remove {}, callback
    , (callback) ->
        Credit.remove {}, callback
    ], done 

  it "should create a user with credits", (done) ->
    @testUser = new User email: "encypt@gmail.com", password: "compl1c4t3d"   
    @testUser.save (err) ->
      User.findOne email: "encypt@gmail.com", (err, user) ->
        throw err  if err
        @credit = new Credit owner: user._id, value: 1
        @credit.save (err) ->
          DataAccess.retrieveCredits user._id, (err, credits) ->
            throw err if err
            credits.length.should.be.equal 1
            credits[0].owner.equals(user._id).should.be.true
            credits[0].value.should.be.equal 1
            done()

  it "should charge a credit to a game", (done) ->
    async.waterfall [(callback) ->
      @game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save (err, item) ->
        throw err if err
        callback null, item
    , (game, callback) ->
      @testUser = new User email: "encypt@gmail.com", password: "compl1c4t3d"
      @testUser.save (err, item) ->
        throw err if err
        callback null, game, item
    , (game, user, callback) ->
      @credit = new Credit owner: user._id, value: 1
      @credit.save (err) ->
        throw err if err
        callback null, game, user
    ], (err, game, user) ->
      DataAccess.chargeCredits user, game, 1, (err) ->
        defined = err?
        defined.should.be.false 
        done()

  it "should fail to charge a credit to a game because of no credits", (done) ->
    async.waterfall [(callback) ->
      @game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save (err, item) ->
        throw err if err
        callback null, item
    , (game, callback) ->
      @testUser = new User email: "encypt@gmail.com", password: "compl1c4t3d"
      @testUser.save (err, item) ->
        throw err if err
        callback null, game, item
    ], (err, game, user) ->
      DataAccess.chargeCredits user, game, 1, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Not enough credits"
        done()

  it "should fail to charge a credit to a game because of to small value", (done) ->
    async.waterfall [(callback) ->
      @game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save (err, item) ->
        throw err if err
        callback null, item
    , (game, callback) ->
      @testUser = new User email: "encypt@gmail.com", password: "compl1c4t3d"
      @testUser.save (err, item) ->
        throw err if err
        callback null, game, item
    , (game, user, callback) ->
      @credit = new Credit owner: user._id, value: 1
      @credit.save (err) ->
        throw err if err
        callback null, game, user
    ], (err, game, user) ->
      DataAccess.chargeCredits user, game, 2, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Not enough credits"
        done()