async = require 'async'
User = require './models/user'
passport = require 'passport'
bcrypt = require 'bcrypt'

class exports.Security

  init: (app, callback) ->

    self=@
    app.use passport.initialize()
    app.use passport.session()

    LocalStrategy = require('passport-local').Strategy
    
    passport.use new LocalStrategy (email, password, done) ->

      process.nextTick ->
        console.log "login called"
        condition = 
          email: email
        blackboard={}
        async.waterfall [
          (callback)->
            User.findOne condition, callback
          (user, callback)->
            if !user 
              return callback "User not found"
            else
              if !bcrypt.compareSync password, user.login_methods.email.password_hash
                return callback "Password is wrong"
            callback null, user
          (user, callback)->
            blackboard.user=user
            callback null, blackboard.user
        ], done

    passport.serializeUser (user, done) ->
      done(null, user._id)

    passport.deserializeUser (id, done) ->
      User.findById id, done  

    app.post '/login', passport.authenticate('local', { successRedirect: '/loggedin',  failureRedirect: '/', failureFlash: true })

    callback null, passport