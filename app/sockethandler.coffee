connect = require 'connect'
cook = require 'cookie'

class exports.SocketHandler

	init: (path, sessionStore, DEBUG, SESSION_SECRET) ->
		path.authorization (data, accept) ->
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

      Game = require('./hangman/game').Game
      game = new Game
      game.init()
    
      path.on "connection", (socket) ->
        hs = socket.handshake
        console.log "debug " + DEBUG
        if DEBUG
          console.log "establishing connection"
          console.log "trying to find user:", hs.user
        User.findById hs.user, (err, user) =>
          return console.log "Couldnt find user:", user if err || !user
          if DEBUG
            console.log "found user by email:", user
          socket.user= user
          user.socket= socket
          if DEBUG
            console.log "A socket with sessionID " + hs.sessionID + " and name: " + user.email + " connected."
          data=
            username:user.email
          socket.emit "loggedin", data

          game.check [], socket

        socket.on 'guess', (data) ->
          #TODO: handle socket event generic
          game.check data, @ 