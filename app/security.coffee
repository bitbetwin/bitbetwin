async = require 'async'
User = require './models/user'
EmailActivator = require './emailActivator'
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
          console.log "--------------------- #{err}" if err
          return done(err) if err
          unless user
            console.log "user not found #{email}"
            return done(null, false, message: "Incorrect username or password.")
          #unless user.activated==true
          #  console.log "got here"
          #  return done(null, false, message: "Your account is not activated, please activate it.")
          user.comparePassword password, (err, isMatch) ->
            throw err if err
            console.log "wrong password--------------------" if !isMatch
            console.log "correct password--------------------" if isMatch
            done(null, false, message: "Incorrect password.") if !isMatch
            done(null, user) if isMatch


    passport.serializeUser (user, done) ->
      done(null, user._id)

    passport.deserializeUser (id, done) ->
      User.findById id, done  

    app.post '/login', passport.authenticate('local', { successRedirect: '/',  failureRedirect: '/', failureFlash: true })

    app.post "/register", (req, res) ->  
      # attach POST to user schema
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
          #login user
          req.login user, (err) ->
            console.log err  if err
            res.redirect "/"

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

