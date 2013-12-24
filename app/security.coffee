async = require 'async'
User = require './models/user'
EmailActivator = require './emailActivator'
passport = require 'passport'
bcrypt = require 'bcrypt'
validator = require 'email-validator'

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
          return done(err) if err
          unless user
            return done(null, false, message: "Incorrect username or password.")
          unless user.activated==true 
           return done(null, false, message: "Please check your emails in order to activate your account #{user.email}")
          user.comparePassword password, (err, isMatch) ->
            throw err if err
            done(null, false, message: "Incorrect password.") if !isMatch
            done(null, user) if isMatch


    passport.serializeUser (user, done) ->
      done(null, user._id)

    passport.deserializeUser (id, done) ->
      User.findById id, done  

    app.post '/login', passport.authenticate('local', { successRedirect: '/',  failureRedirect: '/', failureFlash: true })

    app.post "/register", (req, res) ->  
      # attach POST to user schema

      if !validator.validate(req.body.email)
        res.render "index",
          message: "You have entered an invalid email address"
        return

      user = new User(
        email: req.body.email
        password: req.body.password
      )      

      # save in Mongo
      user.save (err) ->
        if err
          console.log err
        else
          #sending activation email
          emailActivator = new EmailActivator.EmailActivator
          emailActivator.send user, (err) ->
            console.error "error while sending activation link : #{err}" if err
            console.log "activation email send succesfully"    
          res.render "index",
            message: "Please check your emails in order to activate your account #{user.email}"

    app.get "/activate", (req, res) ->
      token = req.query["token"]
      User.findOne token: token, (err, data) ->
        return next(err)  if err
        unless data
          res.send "Token not found. Where are u come from?"
        else
          _email = data.email
          if data.activated is true
            res.send "Your account has already been activated. Just head to the login page."
          else
            data.activated = true
            data.save()
            res.render "index",
              message: "Please sign in " + data.email

