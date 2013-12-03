User = require '../models/user'
mongoose = require "mongoose"

exports.HangmanTest =
    setUp: (callback) ->
        try      
          #db.connection.on('open', function() {
          mongoose.connection.on "open", ->
            console.log "Opened connection"
            callback()

          db = mongoose.connect("mongodb://localhost/bangmanDB")
          console.log "Started connection, waiting for it to open"
          @testUser = new User email: "testing@gmail.com", password: "password"       
        catch err
          console.log "Setting up failed:", err.message

    'test to store a user': (test) ->  
        User.findOne email: "testing@gmail.com" , (err, user) ->
            console.log "no user found, creating new user" + err
            console.log test
            throw err if err
            test.ifError(err);
            test.done()

    getTasks: (test) ->
        console.log "running first test"
        User.find {}, (err, result) ->
            console.log "results" + result
            test.ok result
            test.ifError err
            test.done()
