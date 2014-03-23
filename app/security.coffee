async = require 'async'
EmailActivator = require './emailActivator'
passport = require 'passport'
bcrypt = require 'bcrypt'
validator = require 'email-validator'
BlockchainWallet = require('../app/btc/blockchainWallet').BlockchainWallet
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

        DataAccess.db.User.find(where: condition).complete (err, user) ->
          unless user
            return done(null, false, message: "Incorrect username or password.")
          unless user.activated==true 
           return done(null, false, message: "Please check your emails in order to activate your account #{user.email}")
          user.comparePassword password, (err, isMatch) ->
            throw err if err
            done(null, false, message: "Incorrect username or password.") if !isMatch
            done(null, user) if isMatch


    passport.serializeUser (user, done) ->
      done(null, user.id)

    passport.deserializeUser (id, done) ->
      DataAccess.db.User.find(where: id: id).complete (err, user) ->
        console.log user
        done err, user

    app.post '/login', passport.authenticate('local', { successRedirect: '/',  failureRedirect: '/', failureFlash: true })

    app.post "/register", (req, res) ->  
      # attach POST to user schema

      
      email = req.body.email
      password = req.body.password

      user = DataAccess.db.User.build(
        email: email
        password: password
      )

      if !validator.validate(email)
        res.render "index",
          error: "You have entered an invalid email address"
        return

      # save in Mongo
      
      email = req.body.email
      password = req.body.password
      DataAccess.db.User.find( where: email: email).complete (err, data) ->
        unless data 
          user.save().complete (err, user) ->
            #sending activation email

            if(!DEBUG)
              emailActivator = new EmailActivator.EmailActivator  
              emailActivator.send user, (err) ->
                console.error "error while sending activation link : #{err}" if err
                console.log "activation email send succesfully"
              res.render "index",
                info: "Please check your emails in order to activate your account #{user.email}"
            if err
              console.log err
              #todo render error message
            else
              res.render "index",
                info: "Please check your emails in order to activate your account #{user.email}"
                debug: "Please activate localhost:8080/activate?token=#{user.token}"
        else 
          res.render "index",
            message:  "Email already in use"        


    app.get "/activate", (req, res) ->
      token = req.query["token"]
      DataAccess.db.User.find( token: token).complete (err, user) ->
        return next(err)  if err
        unless user
          res.render "index",
            error: "Token not found. Where are u come from?"
        else
          if user.activated is true
            res.render "index",
              error: "Your account has already been activated. Just head to the login page."
          else
            user.activated = true
            if(!DEBUG)
              blockchainWallet = new BlockchainWallet
              blockchainWallet.init()              
              user.save()
            else  
              user.save()
            res.render "index",
              info: "Please sign in " + user.email

