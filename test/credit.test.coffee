should = require "should"
CreditDao = require "../app/dao/creditdao"
async = require "async"

DataAccess = require "../app/dataaccess"

Promise = require 'promise'

describe "Credit", ->

  #@timeout 15000

  before (done)->
    process.env.NODE_ENV = "testing"
    DataAccess.startup (err, @db) =>
      throw err if err
      done()
    
  beforeEach (done) ->
    #empty database
    async.parallel [(callback) =>
        @db.Game.destroy().success () ->
          callback()
        .error (error) ->
          throw error
          done()
    , (callback) =>
        @db.Credit.destroy().success () ->
          callback()
        .error (error) ->
          throw error
          done()
    , (callback) =>
        @db.User.destroy().success () ->
          callback()
        .error (error) ->
          throw error
          done()
    ], done 

  it "should create a user with credits", (done) ->
    @testUser = @db.User.build email: "encypt@gmail.com", password: "compl1c4t3d"   
    @testUser.save().success (user) =>
      @db.User.find(where: email: "encypt@gmail.com").success (user) =>
        @credit = @db.Credit.build UserId: user.id, GameId: null, value: 1

        @credit.save().success (credit) ->
          CreditDao.retrieveCredits user.id, (err, credits) ->
            throw err if err
            credits.length.should.be.equal 1

            console.log "+++++" + credits[0].UserId + ", " + credits[0].value

            credits[0].UserId.should.be.equal user.id
            credits[0].value.should.be.equal 1

            done()
        .error (error) ->
          throw error
          done()
      .error (error) ->
        throw error
        done()

  it "should charge a credit to a game", (done) ->
    async.waterfall [(callback) =>
      @bank = @db.User.build email: "mail@bitbetwin.co", password: "compl1c4t3d"
      @bank.save().complete (err, item) ->
        throw err if err
        callback null
    , (callback) =>
      @game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save().complete (err, item) ->
        throw err if err
        callback null, item
    , (game, callback) =>
      @testUser = @db.User.build email: "encypt@gmail.com", password: "compl1c4t3d"
      @testUser.save().complete (err, item) ->
        throw err if err
        callback null, game, item
    , (game, user, callback) =>
      @credit = @db.Credit.build UserId: user.id, GameId: null, value: 1
      @credit.save().complete (err) ->
        throw err if err
        callback null, game, user
    , (game, user, callback) =>
      @credit = @db.Credit.build UserId: user.id, GameId: null, value: 1
      @credit.save().complete (err) ->
        throw err if err
        callback null, game, user
    ], (err, game, user) =>
      CreditDao.chargeCredits user.id, game.id, 1, 1, (err) ->
        defined = err?
        defined.should.be.false 
        done()

  it "should fail to charge a credit to a game because of no credits", (done) ->
    async.waterfall [(callback) =>
      @game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save().complete (err, item) ->
        throw err if err
        callback null, item
    , (game, callback) =>
      @testUser = @db.User.build email: "encypt@gmail.com", password: "compl1c4t3d"
      @testUser.save().complete (err, item) ->
        throw err if err
        callback null, game, item
    ], (err, game, user) =>
      CreditDao.chargeCredits user.id, game.id, 1, 1, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Not enough credits"
        done()

  it "should fail to charge a credit to a game because of to small value", (done) ->
    async.waterfall [(callback) =>
      @game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save().complete (err, item) ->
        throw err if err 
        callback null, item
    , (game, callback) =>
      @testUser = @db.User.build email: "encypt@gmail.com", password: "compl1c4t3d"
      @testUser.save().complete (err, item) ->
        throw err if err
        callback null, game, item
    , (game, user, callback) =>
      @credit = @db.Credit.build UserId: user.id, GameId: null, value: 1
      @credit.save().complete (err) ->
        throw err if err
        callback null, game, user
    , (game, user, callback) =>
      @credit = @db.Credit.build UserId: user.id, GameId: null, value: 1
      @credit.save().complete (err) ->
        throw err if err
        callback null, game, user
    ], (err, game, user) =>
      CreditDao.chargeCredits user.id, game.id, 2, 1, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Not enough credits"
        done()

  it "should skip processing if no winners have passed", (done) ->
    async.waterfall [(callback) =>
      bank = @db.User.build email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save().complete (err, item) ->
        throw err if err
        callback null, item
    , (bank, callback) =>
      game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save().complete (err, item) ->
        throw err if err
        callback null, bank, item
    ], (err, bank, game, user1, user2) =>
      throw err if err
      CreditDao.payWinners [], game.id, (err) ->

        console.log " +++++ " + err

        defined = err?
        defined.should.be.false
        done()

  it "should not be possible to split less credits than winners", (done) ->
    async.waterfall [(callback) =>
      bank = @db.User.build email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save().complete (err, item) ->
        throw err if err
        callback null, item
    , (bank, callback) =>
      game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save().complete (err, item) ->
        throw err if err
        callback null, bank, item
    , (bank, game, callback) =>
      user1 = @db.User.build email: "user1@gmail.com", password: "compl1c4t3d"
      user1.save().complete (err, item) ->
        throw err if err
        callback null, bank, game, item
    , (bank, game, user1, callback) =>
      user2 = @db.User.build email: "user2@gmail.com", password: "compl1c4t3d"
      user2.save().complete (err, item) ->
        throw err if err
        callback null, bank, game, user1, item
          
    ], (err, bank, game, user1, user2) ->
      throw err if err
      CreditDao.payWinners [user1, user2], game.id, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Less credits than winners is not possible."
        done()

  it "should pay two winners 2 credits each and 0 remaining not splitable credit to the bank", (done) ->
    async.waterfall [(callback) =>
      bank = @db.User.build email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save().complete (err, item) ->
        throw err if err
        callback null, item
    , (bank, callback) =>
      game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save().complete (err, item) ->
        throw err if err
        callback null, bank, item
    , (bank, game, callback) =>
      user1 = @db.User.build email: "user1@gmail.com", password: "compl1c4t3d"
      user1.save().complete (err, item) ->
        throw err if err
        callback null, bank, game, item
    , (bank, game, user1, callback) =>
      user2 = @db.User.build email: "user2@gmail.com", password: "compl1c4t3d"
      user2.save().complete (err, item) ->
        throw err if err
        callback null, bank, game, user1, item
    , (bank, game, user1, user2, callback) =>
      i = 0
      promises = []
      while i < 4
        credit = @db.Credit.build UserId: bank.id, value: 1, GameId: game.id
        promises.push credit.save().complete (err) ->
          throw err if err
        i++

      Promise.all( promises ).then () ->
        console.log "done"
        callback null, bank, game, user1, user2
          
    ], (err, bank, game, user1, user2) =>
      throw err if err
      CreditDao.payWinners [user1, user2], game.id, (err) ->
        defined = err?
        defined.should.be.false

        CreditDao.retrieveCredits user1.id, (err, credits) ->
          console.log credits.length
          defined = err?
          defined.should.be.false
          credits.length.should.be.equal 2
          CreditDao.retrieveCredits user2.id, (err, credits) ->
            console.log credits.length
            defined = err?
            defined.should.be.false
            credits.length.should.be.equal 2
            CreditDao.retrieveCredits bank.id, (err, credits) ->
              defined = err?
              defined.should.be.false
              credits.length.should.be.equal 0
              done()

  it "should pay two winners 10 credits each and 1 remaining not splitable credit to the bank", (done) ->
    async.waterfall [(callback) =>
      bank = @db.User.build email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save().complete (err, item) ->
        throw err if err
        callback null, item
    , (bank, callback) =>
      game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save (err, item) ->
        throw err if err
        callback null, bank, item
    , (bank, game, callback) =>
      user1 = @db.User.build email: "user1@gmail.com", password: "compl1c4t3d"
      user1.save().complete (err, item) ->
        throw err if err
        callback null, bank, game, item
    , (bank, game, user1, callback) =>
      user2 = @db.User.build email: "user2@gmail.com", password: "compl1c4t3d"
      user2.save().complete (err, item) ->
        throw err if err
        callback null, bank, game, user1, item
    , (bank, game, user1, user2, callback) =>
      i = 0
      promises = []
      while i < 21
        credit = @db.Credit.build UserId: bank.id, value: 1, GameId: game.id
        promises.push credit.save().complete (err) ->
          throw err if err
        i++

      Promise.all( promises ).then () ->
        console.log "done"
        callback null, bank, game, user1, user2
          
    ], (err, bank, game, user1, user2) =>
      throw err if err
      CreditDao.payWinners [user1, user2], game.id, (err) ->
        defined = err?
        defined.should.be.false

        CreditDao.retrieveCredits user1.id, (err, credits) ->
          defined = err?
          defined.should.be.false
          credits.length.should.be.equal 10
          CreditDao.retrieveCredits user2.id, (err, credits) ->
            defined = err?
            defined.should.be.false
            credits.length.should.be.equal 10
            CreditDao.retrieveCredits bank.id, (err, credits) ->
              defined = err?
              defined.should.be.false
              credits.length.should.be.equal 1
              done()

  it "should fail to charge a credit to a game because of to small bet", (done) ->
    async.waterfall [(callback) =>
      @bank = @db.User.build email: "mail@bitbetwin.co", password: "compl1c4t3d"
      @bank.save().complete (err, item) ->
        throw err if err
        callback null
    , (callback) =>
      @game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      @game.save().complete (err, item) ->
        throw err if err
        callback null, item
    , (game, callback) =>
      @testUser = @db.User.build email: "encypt@gmail.com", password: "compl1c4t3d"
      @testUser.save().complete (err, item) ->
        throw err if err
        callback null, game, item
    , (game, user, callback) =>
      @credit = @db.Credit.build UserId: user.id, GameId: null, value: 1
      @credit.save().complete (err) ->
        throw err if err
        callback null, game, user
    , (game, user, callback) =>
      @credit = @db.Credit.build UserId: user.id, GameId: null, value: 1
      @credit.save().complete (err) ->
        throw err if err
        callback null, game, user
    ], (err, game, user) =>
      CreditDao.chargeCredits user.id, game.id, -1, -1, (err) ->
        defined = err?
        defined.should.be.true
        err.should.be.equal "Too small bet"
        done()

  it "should retrieve all credits in pot", (done) ->
    gamefx = (resolve, reject) =>
      game = @db.Game.build name: "testgame1", phrasegenerator: "singlephrasegenerator", durationcalculator: "simpledurationcalculator"   
      game.save().complete (err, game) ->
        return reject err if err
        resolve game

    bankfx = (resolve, reject) =>
      bank = @db.User.build email: "mail@bitbetwin.co", password: "compl1c4t3d"
      bank.save().complete (err, bank) ->
        return reject err if err
        resolve bank

    userfx = (resolve, reject) =>
      user = @db.User.build email: "user@gmail.com", password: "compl1c4t3d"
      user.save().complete (err, user) ->
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
        credit = @db.Credit.build UserId: user.id, value: 1
        credit.save().complete (err, credit) ->
          return reject err if err
          resolve credit

      creditPromises = []

      i=0
      while i < 21
        creditPromises.push new Promise(creditfx) 
        i++

      Promise.all( creditPromises ).then (credits) ->
        CreditDao.chargeCredits user.id, game.id, 10, 2, (err) ->
          defined = err?
          defined.should.be.false

          CreditDao.retrievePot game.id, (err, credits) ->
            defined = err?
            defined.should.be.false
            credits.length.should.be.equal 10
            done()