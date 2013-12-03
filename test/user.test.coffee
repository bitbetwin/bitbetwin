User = require "../app/models/user"
should = require "should"

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
    User.remove {}, done
  
  it "looks for a nonexisting user in db", (done) ->
    User.findOne email: "nonexisting@gmail.com" , (err, user) ->
      defined = user?
      defined.should.be.false
      done()

  it "looks for a nonexisting user in db", (done) ->
      @testUser = new User email: "testing@gmail.com", password: "password"   
      @testUser.save (err) ->
        noError = !err?
        noError.should.be.true
        done()