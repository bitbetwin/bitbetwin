User = require "../app/models/user"
should = require "should"
async = require "async"


restful = require 'node-restful'
mongoose = restful.mongoose

describe "User", ->

  before (done)->
    mongoose.connect "mongodb://localhost/bangmandbTest"
    db = mongoose.connection
    db.on 'error', done
    db.once 'open', done

  after (done)->
    mongoose.connection.close()
    done()
    
  beforeEach (done)->
    User.remove {}, done #empty database
  
  it "looks for a nonexisting user in db", (done) ->
    User.findOne email: "nonexisting@gmail.com" , (err, user) ->
      defined = user?
      defined.should.be.false
      done()

  it "creates a user", (done) ->
    @testUser = new User email: "encypt@gmail.com", password: "compl1c4t3d"   
    @testUser.save (err) ->
    # fetch user and test password verification
      User.findOne email: "encypt@gmail.com", (err, user) ->
        throw err  if err
        done()  
          

  it "creates a user and tests encryption", (done) ->
    async.waterfall [(callback) ->
      @testUser = new User email: "encypt@gmail.com", password: "compl1c4t3d"   
      @testUser.save (err) ->        
        callback null, @testUser
    , (arg2, callback) ->
      User.findOne email: "encypt@gmail.com", (err, user) ->
        throw err  if err
        callback err, user
    , (arg1, callback) ->
      arg1.comparePassword "compl1c4t3d", (err, isMatch) ->
        throw err  if err
        callback null, arg1, isMatch
    , (user, arg1, callback) ->
      user.comparePassword "123Password", (err, isMatch) ->
        throw err  if err
        isMatch.should.be.fase
        callback null, arg1, isMatch
    ], (err, result1, result2) ->      
      result1.should.be.true
      result2.should.be.fase
      done()  