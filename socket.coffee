request = require 'request'
socketio = require 'socket.io'
express = require 'express'

DEBUG = false

class exports.Server

  constructor: (@port) ->

    @connect = require 'connect'

    MemoryStore = express.session.MemoryStore

    @app = express()

    # convert existing coffeescript, styl, and less resources to js and css for the browser
    @app.use require('connect-assets') src: __dirname + '/public'


    @app.set 'views', __dirname + '/app/views'
    @app.set 'view engine', 'jade'
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    
    @app.use express.static(__dirname + '/public')
    @app.use express.cookieParser('guess')
    @app.use express.session { secret :'ci843tgbza11e', key: 'sessionID'}

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
    DEBUG = (process.env.DEBUG=="true")
    console.log "DEBUG flag:", DEBUG

    console.log 'Server starting'
    @http_server=@app.listen @port
    console.log 'Server listening on port ' + @port
   
    @app.get '/', (req, res) =>
      console.log "/ called "
      vars=
        foo: true
      res.render('index', vars)

    #TODO move partial templates into subfolder
    @app.get '/guess', (req, res) =>
      res.render('guess')

    # Socket IO
    @public=(socketio.listen @http_server)
    @public.sockets.on 'connection', (socket) ->
      socket.emit('news', { hello: 'world' })
    

  stop: (callback) ->
    console.log "Stop called"
    @private.server.close()
    callback()
