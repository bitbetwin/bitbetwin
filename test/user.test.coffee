should = require "should"
async = require "async"
validator = require("email-validator")

DataAccess = require "../app/dataaccess"

describe "User", ->

  before (done)->
    process.env.NODE_ENV = "testing"
    DataAccess.startup (err, @db) =>
      throw err if err
      done()
    
  beforeEach (done) ->
    @db.User.destroy().success () ->
      done()
    .error (error) ->
      throw error
      done()
  
  it "looks for a nonexisting user in db", (done) ->
    @db.User.find( where: 
      email: "nonexisting@gmail.com"
    ).success((user) ->
        defined = user?
        defined.should.be.false
        done()
    ).error((error) ->
        throw error)

  it "creates a user", (done) ->
    @testUser = @db.User.build email: "encypt@gmail.com", password: "compl1c4t3d"
    @testUser.save().success (user) =>
    # fetch user and test password verification
      @db.User.find(where: email: "encypt@gmail.com").success((user) ->
        done()
      ).error((error) ->
        throw error
        done())
          

  it "creates a user and tests encryption", (done) ->
    async.waterfall [(callback) =>
      @testUser = @db.User.build email: "encypt@gmail.com", password: "compl1c4t3d"   
      @testUser.save().complete (err, user) ->        
        throw err if err
        callback err, user
    , (arg2, callback) =>
      @db.User.find( where: email: "encypt@gmail.com" ).complete (err, user) ->
        throw err if err
        callback err, user
    , (user, callback) ->
      user.comparePassword "compl1c4t3d", (err, isMatch) ->
        throw err  if err
        callback null, user, isMatch
    , (user, arg1, callback) ->
      user.comparePassword "123Password", (err, isMatch) ->
        throw err  if err
        isMatch.should.be.false
        callback null, arg1, isMatch
    ], (err, result1, result2) ->      
      result1.should.be.true
      result2.should.be.false
      done()  

  it "should validate a email address" , (done) ->
    valid = validator.validate("test@email.com")
    valid.should.be.true
    valid = validator.validate("test@emailcom")
    valid.should.be.false
    done()