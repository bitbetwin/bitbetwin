async = require 'async'
User = require './models/user'
EmailActivator = require './emailActivator'
passport = require 'passport'
bcrypt = require 'bcrypt'
validator = require 'email-validator'
DataAccess = require './dataaccess'

class exports.Security

  init: (app, callback) ->
    DEBUG = DataAccess.loadConfig().debug
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
          unless user
            return done(null, false, message: "Incorrect username or password.")
          unless user.activated==true 
           return done(null, false, message: "Please check your emails in order to activate your account #{user.email}")
          user.comparePassword password, (err, isMatch) ->
            throw err if err
            done(null, false, message: "Incorrect username or password.") if !isMatch
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
          error: "You have entered an invalid email address"
        return

      condition = 
          email: req.body.email
      User.findOne condition, (err, user) ->
        if user?
          if !user.activated
            res.render "index",
              info: "Please check your emails in order to activate your account #{user.email}"
          else 
            res.render "index",
              error: "The user #{user.email} is already registered. Forgot your password?"
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
            if(!DEBUG)
              emailActivator.send user, (err) ->
                console.error "error while sending activation link : #{err}" if err
                console.log "activation email send succesfully"
              res.render "index",
                info: "Please check your emails in order to activate your account #{user.email}"
            else
              res.render "index",
                info: "Please check your emails in order to activate your account #{user.email}"
                debug: "Please activate localhost:8080/activate?token=#{user.token}"

          

    app.get "/activate", (req, res) ->
      token = req.query["token"]
      User.findOne token: token, (err, data) ->
        return next(err)  if err
        unless data
          res.send "Token not found. Where are u come from?"
        else
          _email = data.email
          if data.activated is true
            res.render "index",
              error: "Your account has already been activated. Just head to the login page."
          else
            data.activated = true
            data.save()
            res.render "index",
              info: "Please sign in " + data.email

