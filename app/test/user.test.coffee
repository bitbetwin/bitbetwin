User = require '../models/user'

restful = require 'node-restful'
mongoose = restful.mongoose

exports.UserTest =
    setUp: (callback) ->
      try      
        mongoose.connection.on "open", ->
          callback()
        db = mongoose.connect("mongodb://localhost/bangmandb")
      catch err
        console.log "Setting up failed:", err.message

    tearDown: (callback) ->
      mongoose.disconnect()
      callback()  
          
        
    'test cread read update': (test) ->  
      User.findOne email: "nonexisting@gmail.com" , (err, user) -> 
        test.equal(user?, false, "user should note be defined")
        test.done()    
        
    'test create new user': (test) ->
      @testUser = new User email: "testing@gmail.com", password: "password"   
      console.log @testUser    
      @testUser.save (err) -> 
        console.log err 
        test.done()    