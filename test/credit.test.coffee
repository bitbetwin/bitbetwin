Credit = require "../app/models/credit"
User = require "../app/models/user"
Game = require "../app/models/game"

should = require "should"
CreditDao = require "../app/dao/creditdao"
async = require "async"

restful = require 'node-restful'
mongoose = restful.mongoose

Promise = require 'promise'

describe "Credit", ->

  @timeout 15000

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
    , (callback) ->
        User.remove {}, callback
    ], done 

  it "should create a user with credits", (done) ->
    @testUser = new User email: "encypt@gmail.com", password: "compl1c4t3d"   
    @testUser.save (err) ->
      User.findOne email: "encypt@gmail.com", (err, user) ->
        throw err  if err
        @credit = new Credit owner: user._id, game: null, value: 1
        @credit.save (err) ->
          CreditDao.retrieveCredits user._id, (err, credits) ->
            throw err if err
            credits.length.should.be.equal 1
            credits[0].owner.equals(user._id).should.be.true
            credits[0].value.should.be.equal 1
            done()

  it "should charge a credit to a game", (done) ->
    async.waterfall [(callback) ->
      @bank = new User email: "mail@bitbetwin.co", password: "compl1c4t3d"
      @bank.save (err, item) ->
        throw err if err
        callback null
    , (callback) ->
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
      @credit = new Credit owner: user._id, game: null, value: 1
      @credit.save (err) ->
        throw err if err
        callback null, game, user
    , (game, user, callback) ->
      @credit = new Credit owner: user._id, game: null, value: 1
      @credit.save (err) ->
        throw err if err
        callback null, game, user
    ], (err, game, user) ->
      CreditDao.chargeCredits user, game, 1, 1, (err) ->
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
      CreditDao.chargeCredits user, game, 1, 1, (err) ->
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
      @credit = new Credit owner: user._id, game: null, value: 1
      @credit.save (err) ->
        throw err if err
        callback null, game, user
    , (game, user, callback) ->
      @credit = new Credit owner: user._id, game: null, value: 1
      @credit.save (err) ->
        throw err if err
        callback null, game, user
    ], (err, game, user) ->
      CreditDao.chargeCredits user, game, 2, 1, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Not enough credits"
        done()

  it "should skip processing if no winners are passed", (done) ->
    async.waterfall [(callback) ->
      bank = new User email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save (err, item) ->
        throw err if err
        callback null, item
    , (bank, callback) ->
      game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save (err, item) ->
        throw err if err
        callback null, bank, item
          
    ], (err, bank, game, user1, user2) ->
      throw err if err
      CreditDao.payWinners [], game._id, (err) ->
        defined = err?
        defined.should.be.false
        done()

  it "should not be possible to split less credits than winners", (done) ->
    async.waterfall [(callback) ->
      bank = new User email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save (err, item) ->
        throw err if err
        callback null, item
    , (bank, callback) ->
      game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save (err, item) ->
        throw err if err
        callback null, bank, item
    , (bank, game, callback) ->
      user1 = new User email: "user1@gmail.com", password: "compl1c4t3d"
      user1.save (err, item) ->
        throw err if err
        callback null, bank, game, item
    , (bank, game, user1, callback) ->
      user2 = new User email: "user2@gmail.com", password: "compl1c4t3d"
      user2.save (err, item) ->
        throw err if err
        callback null, bank, game, user1, item
          
    ], (err, bank, game, user1, user2) ->
      throw err if err
      CreditDao.payWinners [user1, user2], game._id, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Less credits than winners is not possible."
        done()

  it "should pay two winners 2 credits each and 0 remaining not splitable credit to the bank", (done) ->
    async.waterfall [(callback) ->
      bank = new User email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save (err, item) ->
        throw err if err
        callback null, item
    , (bank, callback) ->
      game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save (err, item) ->
        throw err if err
        callback null, bank, item
    , (bank, game, callback) ->
      user1 = new User email: "user1@gmail.com", password: "compl1c4t3d"
      user1.save (err, item) ->
        throw err if err
        callback null, bank, game, item
    , (bank, game, user1, callback) ->
      user2 = new User email: "user2@gmail.com", password: "compl1c4t3d"
      user2.save (err, item) ->
        throw err if err
        callback null, bank, game, user1, item
    , (bank, game, user1, user2, callback) ->
      i = 0
      promises = []
      while i < 4
        credit = new Credit owner: bank._id, value: 1, game: game._id
        promises.push credit.save (err) ->
          throw err if err
        i++

      Promise.all( promises ).then () ->
        console.log "done"
        callback null, bank, game, user1, user2
          
    ], (err, bank, game, user1, user2) ->
      throw err if err
      CreditDao.payWinners [user1, user2], game._id, (err) ->
        defined = err?
        defined.should.be.false

        CreditDao.retrieveCredits user1._id, (err, credits) ->
          defined = err?
          defined.should.be.false
          credits.length.should.be.equal 2
          CreditDao.retrieveCredits user2._id, (err, credits) ->
            defined = err?
            defined.should.be.false
            credits.length.should.be.equal 2
            CreditDao.retrieveCredits bank._id, (err, credits) ->
              defined = err?
              defined.should.be.false
              credits.length.should.be.equal 0
              done()

  it "should pay two winners 10 credits each and 1 remaining not splitable credit to the bank", (done) ->
    async.waterfall [(callback) ->
      bank = new User email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save (err, item) ->
        throw err if err
        callback null, item
    , (bank, callback) ->
      game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save (err, item) ->
        throw err if err
        callback null, bank, item
    , (bank, game, callback) ->
      user1 = new User email: "user1@gmail.com", password: "compl1c4t3d"
      user1.save (err, item) ->
        throw err if err
        callback null, bank, game, item
    , (bank, game, user1, callback) ->
      user2 = new User email: "user2@gmail.com", password: "compl1c4t3d"
      user2.save (err, item) ->
        throw err if err
        callback null, bank, game, user1, item
    , (bank, game, user1, user2, callback) ->
      i = 0
      promises = []
      while i < 21
        credit = new Credit owner: bank._id, value: 1, game: game._id
        promises.push credit.save (err) ->
          throw err if err
        i++

      Promise.all( promises ).then () ->
        console.log "done"
        callback null, bank, game, user1, user2
          
    ], (err, bank, game, user1, user2) ->
      throw err if err
      CreditDao.payWinners [user1, user2], game._id, (err) ->
        defined = err?
        defined.should.be.false

        CreditDao.retrieveCredits user1._id, (err, credits) ->
          defined = err?
          defined.should.be.false
          credits.length.should.be.equal 10
          CreditDao.retrieveCredits user2._id, (err, credits) ->
            defined = err?
            defined.should.be.false
            credits.length.should.be.equal 10
            CreditDao.retrieveCredits bank._id, (err, credits) ->
              defined = err?
              defined.should.be.false
              credits.length.should.be.equal 1
              done()

  it "should fail to charge a credit to a game because of to small bet", (done) ->
    async.waterfall [(callback) ->
      @bank = new User email: "mail@bitbetwin.co", password: "compl1c4t3d"
      @bank.save (err, item) ->
        throw err if err
        callback null
    , (callback) ->
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
      @credit = new Credit owner: user._id, game: null, value: 1
      @credit.save (err) ->
        throw err if err
        callback null, game, user
    , (game, user, callback) ->
      @credit = new Credit owner: user._id, game: null, value: 1
      @credit.save (err) ->
        throw err if err
        callback null, game, user
    ], (err, game, user) ->
      CreditDao.chargeCredits user._id, game._id, -1, -1, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Too small bet"
        done()

  it "should retrieve all credits in pot", (done) ->
    gamefx = (resolve, reject) =>
      game = new Game name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save (err, game) ->
        return reject err if err
        resolve game

    bankfx = (resolve, reject) =>
      bank = new User email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save (err, bank) ->
        return reject err if err
        resolve bank

    userfx = (resolve, reject) =>
      user = new User email: "user@gmail.com", password: "compl1c4t3d"
      user.save (err, user) ->
        return reject err if err
        resolve user

    gamePromise = new Promise(gamefx)
    bankPromise = new Promise(bankfx)
    userPromise = new Promise(userfx)
    promises = []
    promises.push gamePromise
    promises.push bankPromise
    promises.push userPromise

    Promise.all( promises ).then (results) ->
      game = results[0]
      bank = results[1]
      user = results[2]

      creditfx = (resolve, reject) =>
        credit = new Credit owner: user._id, value: 1
        credit.save (err, credit) ->
          return reject err if err
          resolve credit

      creditPromises = []

      i=0
      while i < 21
        creditPromises.push new Promise(creditfx) 
        i++

      Promise.all( creditPromises ).then (credits) ->

        CreditDao.chargeCredits user._id, game._id, 10, 2, (err) ->
          defined = err?
          defined.should.be.false

          CreditDao.retrievePot game._id, (err, credits) ->
            defined = err?
            defined.should.be.false
            credits.length.should.be.equal 10
            done()