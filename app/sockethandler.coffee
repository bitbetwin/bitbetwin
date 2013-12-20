connect = require 'connect'
cook = require 'cookie'
socketio = require 'socket.io'

class exports.SocketHandler

	init: (io, sessionStore, DEBUG, SESSION_SECRET) ->
    #TODO: handle game instances generic
    Game = require('./hangman/game').Game
    game1 = new Game io, 'game1'
    game1.start()
    game2 = new Game io, 'game2'
    game2.start()

    io.authorization (data, accept) ->
      if DEBUG 
        console.log "authorization called with cookies:", data?.headers?.cookie
      if data.headers.cookie
        cookie = cook.parse(data.headers.cookie)
      else
        cookie = data.query
      # NOTE: To detect which session this socket is associated with,
      # we need to parse the cookies.
      return accept("Session cookie required.", false)  unless cookie

      # NOTE: Next, verify the signature of the session cookie.
      data.cookie = connect.utils.parseSignedCookies(cookie, SESSION_SECRET)

      # NOTE: save ourselves a copy of the sessionID.
      data.sessionID = data.cookie["sessionID"]

      sessionStore.get data.sessionID, (err, session) ->
        if err
          return accept("Error in session store." + err, false)
        else return accept("Session not found.", false) unless session

        if (!session.passport.user)
          return accept("NO User in session found.", false)
        
        # success! we're authenticated with a known session.
        data.session = session
        data.user = session.passport.user
        accept null, true

      User = require('./models/user')
    
      io.on "connection", (socket) ->
        hs = socket.handshake
        console.log "debug " + DEBUG
        if DEBUG
          console.log "establishing connection"
          console.log "trying to find user:", hs.user
        User.findById hs.user, (err, user) =>
          return console.log "Couldnt find user:", user if err || !user
          if DEBUG
            console.log "found user by email:", user
          socket.user = user
          user.socket = socket
          if DEBUG
            console.log "A socket with sessionID " + hs.sessionID + " and name: " + user.email + " connected."
          data = { username: user.email, games: [ {name: game1.name }, {name: game2.name}] }
          socket.emit "loggedin", data

        #TODO: add generic handling of socket events
        #TODO: handle game instance generic
        socket.on 'guess', (data) ->
          if (@.game.name == 'game1')
            game1.check @, data
          if (@.game.name == 'game2')
            game2.check @, data

        socket.on 'join', (data) ->
          if (data == 'game1')
            game1.join @
          if (data == 'game2')
            game2.join @

        socket.on 'leave', () ->
          if (data == 'game1')
            game1.leave @
          if (data == 'game2')
            game2.leave @
          data = { username: @.user.email, games: [ {name: game1.name }, {name: game2.name}] }
          socket.emit "loggedin", data