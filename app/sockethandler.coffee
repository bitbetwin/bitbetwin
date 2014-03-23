connect = require 'connect'
cook = require 'cookie'
socketio = require 'socket.io'
CreditDao = require './dao/creditdao'
GameDao = require './dao/gamedao'
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

    io.on "connection", (socket) ->
      hs = socket.handshake
      @.log.info "debug " + DEBUG
      if DEBUG
        @.log.info "establishing connection"
        @.log.info "trying to find user:", hs.user

      logger = @.log
      user = connectedUsers[hs.user]
      sendLoginData= (user) => 
        socket.user = user
        user.sockets.push socket
        logger.debug "A socket with sessionID " + hs.sessionID + " and name: " + user.email + " connected."
        
        connectedUsers[hs.user] = user

        GameDao.retrieveGames (err, games) ->
          socket.emit "loggedin", games

        CreditDao.retrieveCredits user._id, (err, credits) ->
          socket.user.credits = credits.length
          socket.emit "wallet", { credits: credits.length }

      if user
        console.log "user reused " + user
        sendLoginData user
      else 
        console.log "get user from db"
        DataAccess.db.User.find( where: id: hs.user ).complete (err, user) =>
          return @.log.warn "Couldnt find user:", user if err || !user
          if DEBUG
            @.log.debug "found user by email:", user
          user.sockets = []
          sendLoginData(user)

      origemit = socket.$emit

      socket.$emit = () ->
        event = arguments[0]
        feed  = arguments[1]
        callback = arguments[2]
        @.log.debug event + ":" + feed

        gameevent = false

        if event == 'join' && GameDao.commands[feed]? && ( event in GameDao.commands[feed]['functions'] )
          result = GameDao.commands[feed]['instance'][event] @, feed, callback
          gameevent = true
        else
          if GameDao.commands[@.game?.name]? && ( event in GameDao.commands[@.game?.name]['functions'] )
            result = GameDao.commands[@.game?.name]['instance'][event] @, feed, callback
            gameevent = true

        if !gameevent
          @.log.warn "no game event"

          origemit.apply @, Array.prototype.slice.call arguments

      socket.on "disconnect", () ->
        socket.user.sockets.splice(socket)
        @.log.debug "A socket with sessionID " + hs.sessionID + " disconnected!"