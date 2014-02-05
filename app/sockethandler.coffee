connect = require 'connect'
cook = require 'cookie'
socketio = require 'socket.io'
DataAccess = require './dataaccess'

class exports.SocketHandler

	init: (io, sessionStore, DEBUG, SESSION_SECRET) ->

    connectedUserIds = []
    userSessions = {}
    connectedUsers= {}
    io.authorization (data, accept) ->
      if DEBUG 
        @.log.debug "authorization called with cookies:", data?.headers?.cookie
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
        if session.passport.user in connectedUserIds
          console.info "user reconnected from different window"
          session = userSessions[session.passport.user]
        else 
          console.info "user first time login "
          connectedUserIds.push session.passport.user
          userSessions[session.passport.user]=session
        data.session = session
        data.user = session.passport.user
        accept null, true

    User = require('./models/user')

    io.on "connection", (socket) ->
      hs = socket.handshake
      @.log.info "debug " + DEBUG
      if DEBUG
        @.log.info "establishing connection"
        @.log.info "trying to find user:", hs.user

      
      user = connectedUsers[hs.user]
      sendLoginData= (user) => 
        socket.user = user
        user.sockets.push socket
        if DEBUG
          @.log.debug "A socket with sessionID " + hs.sessionID + " and name: " + user.email + " connected."
        connectedUsers[hs.user] = user
        data = DataAccess.retrieveGames()
        socket.emit "loggedin", data        

      if user
        console.log "user reused " + user
        sendLoginData(user)
      else 
        console.log "get user from db"
        User.findById hs.user, (err, user) =>
          return @.log.warn "Couldnt find user:", user if err || !user
          if DEBUG
            @.log.debug "found user by email:", user
          user.sockets = []
          sendLoginData(user)

      x = socket.$emit

      socket.$emit = () ->
        event = arguments[0]
        feed  = arguments[1]
        callback = arguments[2]
        @.log.debug event + ":" + feed

        gameevent = false

        if event == 'join' && DataAccess.commands[feed]? && ( event in DataAccess.commands[feed]['functions'] )
          result = DataAccess.commands[feed]['instance'][event] @, feed
          gameevent = true
        else
          if DataAccess.commands[@.game?.name]? && ( event in DataAccess.commands[@.game?.name]['functions'] )
            result = DataAccess.commands[@.game?.name]['instance'][event] @, feed
            gameevent = true

        if gameevent
          @.log.warn "game event"
          callback result
        else
          @.log.warn "no game event"
          x.apply @, Array.prototype.slice.call arguments
      socket.on "disconnect", () ->
        @.log.debug "A socket with sessionID " + hs.sessionID + " disconnected!"
      
