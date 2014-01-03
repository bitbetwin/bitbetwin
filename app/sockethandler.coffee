connect = require 'connect'
cook = require 'cookie'
socketio = require 'socket.io'
DataAccess = require './dataaccess'

class exports.SocketHandler

	init: (io, sessionStore, DEBUG, SESSION_SECRET) ->

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
      User.findById hs.user, (err, user) =>
        return @.log.warn "Couldnt find user:", user if err || !user
        if DEBUG
          @.log.debug "found user by email:", user
        socket.user = user
        user.socket = socket
        if DEBUG
          @.log.debug "A socket with sessionID " + hs.sessionID + " and name: " + user.email + " connected."
        data = DataAccess.retrieveGames()
        socket.emit "loggedin", data

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
