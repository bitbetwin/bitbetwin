request = require 'request'
socketio = require 'socket.io'
express = require 'express'

MongoStore = require('connect-mongo')(express)
ObjectId = require('mongoose').Types.ObjectId

DataAccess = require './app/dataaccess'

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

    @SESSION_SECRET = "ci843tgbza11e"
    @DEBUG = config.debug

    flash = require 'connect-flash'

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

    @app.use express.session { secret :@SESSION_SECRET, store: @sessionStore, key: 'sessionID'}

    # error message handling
    @app.use(flash())
    
    #security stuff, aka login, authentication
    Security = require('./app/security').Security
    security = new Security
    security.init @app, (error, passport) =>
      @app.use @app.router

    #Subscriber
    Subscribe = require('./app/subscribe').Subscribe
    subscribe = new Subscribe
    subscribe.init @app

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
   
    HttpHandler = require('./app/httphandler').HttpHandler
    httpHandler = new HttpHandler
    httpHandler.init @app

    # Socket IO
    @public=(socketio.listen @http_server)

    @private = @public.of "/auth"

    SocketHandler = require('./app/sockethandler').SocketHandler
    socketHandler = new SocketHandler
    socketHandler.init @private, @sessionStore, @DEBUG, @SESSION_SECRET

    DataAccess.startup()

    return callback() # finishes start function

        
  stop: (callback) ->
    console.log "Stop called"
    DataAccess.shutdown()
    @private.server.close()
    callback()