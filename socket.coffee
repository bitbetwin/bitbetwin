request = require 'request'
socketio = require 'socket.io'
express = require 'express'
Hangman = require './app/hangman'

restful = require 'node-restful'
mongoose = restful.mongoose

MongoStore = require('connect-mongo')(express)
ObjectId = require('mongoose').Types.ObjectId

User = require './app/models/user'

#settings
switch process.env.NODE_ENV
  when "development" 
    env = "development"
  when "production"
    env = "production" 
  else
    env = "development" # default development for now

config = require("./app/config/config")[env]

class exports.Server

  constructor: (@port) ->

    console.log env + " mode started"
    
    @DEBUG = config.debug

    @connect = require 'connect'
    flash = require 'connect-flash'

    MemoryStore = express.session.MemoryStore
    @sessionStore = new MongoStore url: config.db_address

    @app = express()

    # convert existing coffeescript, styl, and less resources to js and css for the browser
    @app.use require('connect-assets') src: __dirname + '/public'


    @app.set 'views', __dirname + '/app/views'
    @app.set 'view engine', 'jade'
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    
    @app.use express.static(__dirname + '/public')
    @app.use '/components', express.static(__dirname + '/bower_components');
    @app.use express.cookieParser('guess')
    @app.use express.session { secret :'ci843tgbza11e', store: @sessionStore, key: 'sessionID'}

    # error message handling
    @app.use(flash())
    
    #security stuff, aka login, authentication
    Security = require('./app/security').Security
    security = new Security
    security.init @app, (error, passport) =>
      @app.use @app.router

    #development
    @app.use(express.errorHandler({
      dumpExceptions: true, showStack: true
    }))

    # logging
    logger= (req, res, next) ->
      console.log "GOT REQUEST !", req.originalUrl, req.query
      next(); 

    @app.use logger


  start: (callback) ->
    console.log "DEBUG flag:", @DEBUG

    console.log 'Server starting on port ' + @port
    @http_server=@app.listen @port
   
    @app.get '/', (req, res) =>
      console.log "/ called "
      vars=
        user: req.user
      res.render('index', vars)

    #TODO move partial templates into subfolder
    @app.get '/guess', (req, res) =>
      res.render('guess')

    # Landingpage route
    @app.get '/landingpage', (req, res) => 
      res.render('landingpage')

    @app.get '/login', (req, res) ->
      res.render('login', {user: req.user, message: req.flash('error')})

    mongoose.connect config.db_address, (error) ->
      console.log "could not connecte because: " + error if error
    db = mongoose.connection

    db.on 'error', console.error.bind(console, 'Mongo DB connection error:')
    
    db.once 'open', (callback) ->
      console.log "connected with mongodb"
      
    #create a user a new user    
    testUser = new User email: "user", password: "password"
    User.findOne email: testUser.email , (err, user) ->
        console.log "no user found, creating new user" if err
        throw err if err
        if !user? 
          testUser.save (err) -> 
            console.log "user saved" unless err            
            throw err if err          
            # fetch user and test password verification
      
    # Socket IO
    @public=(socketio.listen @http_server)

    hangman = new Hangman 'Congratulations you guessed the sentence correctly'

    @public.sockets.on 'connection', (socket) ->
      hangman.check [], (match) -> 
        socket.emit('hangman', { phrase: match })

      socket.on 'guess', (data) -> 
        hangman.check data, (match) -> 
          socket.emit('hangman', { phrase: match })

    return callback() # finishes start function

        
  stop: (callback) ->
    console.log "Stop called"
    mongoose.disconnect()
    @private.server.close()
    callback()
