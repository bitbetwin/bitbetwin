User = require '../models/user'

restful = require 'node-restful'
mongoose = restful.mongoose

exports.HangmanTest =
    setUp: (callback) ->
      try      
        mongoose.connection.on "open", ->
          callback()
        db = mongoose.connect("mongodb://localhost/bangmandb")
        @testUser = new User email: "testing@gmail.com", password: "password"       
      catch err
        console.log "Setting up failed:", err.message
    tearDown: (callback) ->
      mongoose.disconnect()
      callback()  
        
    'test to find non existing user': (test) ->  
      User.findOne email: "nonexisting@gmail.com" , (err, user) -> 
        test.equal(user?, false, "user should note be defined")
        test.done()    
        