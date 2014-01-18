Credit = require "../app/models/credit"
User = require "../app/models/user"

should = require "should"
DataAccess = require "../app/dataaccess"
async = require "async"

restful = require 'node-restful'
mongoose = restful.mongoose

describe "Credit", ->

  before (done)->
    mongoose.connect "mongodb://localhost/bangmandbTest"
    db = mongoose.connection
    db.on 'error', done
    db.once 'open', done

  after (done)->
    mongoose.connection.close()
    done()
    
  beforeEach (done)->
    Credit.remove {}, done #empty database

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