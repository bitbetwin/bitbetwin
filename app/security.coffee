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
    
    passport.use new LocalStrategy 
      usernameField: 'email',
      passwordField: 'password'
    , (email, password, done) ->

      process.nextTick ->
        condition = 
          email: email
        User.findOne condition, (err, user) ->
          return done(err)  if err
          unless user
            return done(null, false,
              message: "Incorrect username or password."
            )
          unless user.password==password #TODO encrypt password
            return done(null, false, message: "Incorrect password.")
          done null, user


    passport.serializeUser (user, done) ->
      done(null, user._id)

    passport.deserializeUser (id, done) ->
      User.findById id, done  

    app.post '/login', passport.authenticate('local', { successRedirect: '/',  failureRedirect: '/', failureFlash: true })

    callback null, passport