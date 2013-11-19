async = require "async"
request = require 'request'
socketio = require 'socket.io'
path = require 'path'

express = require 'express'

DEBUG = true

class exports.Server

  constructor: (@port) ->

    @connect = require 'connect'

    MemoryStore = express.session.MemoryStore

    @app = express()

    # convert existing coffeescript, styl, and less resources to js and css for the browser
    @app.use require('connect-assets') src: __dirname + '/public'


    @app.set 'views', __dirname + '/client/pages'
    @app.set 'view engine', 'jade'
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    @app.use require('stylus').middleware src: __dirname + '/public' 
    @app.use(express.static(__dirname + '/public'))
    @app.use(express.cookieParser('test'))
    @app.use(express.session { secret :'civ9Ohlaiza11e', store: MemoryStore, key: 'sessionID'})

    #development
    @app.use(express.errorHandler({
      dumpExceptions: true, showStack: true
    }))


    @session_handler = new SessionHandler
    @email_handler = new EmailHandler

    # logging
    logger= (req, res, next) ->
      console.log "GOT REQUEST !", req.originalUrl, req.query
      next(); 

    @app.use logger

  start: (callback) ->
    DEBUG = (process.env.DEBUG=="true")
    console.log "DEBUG flag:", DEBUG

    console.log 'Server starting'
    @http_server=@app.listen @port
    console.log 'Server listening on port ' + @port
   
    @app.get '/', (req, res) =>
      console.log "/ called "
      res.render('app', vars)


    # Socket IO
    @public=(socketio.listen @http_server)
    @private = @public.of "/auth"
    

  stop: (callback) ->
    console.log "Stop called"
    #@private.server.close()
    mongoose.connection.close()
    callback()