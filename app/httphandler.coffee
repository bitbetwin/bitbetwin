Security = require('./security').Security

class exports.HttpHandler
  init: (app) ->
    app.get '/', (req, res) ->
      vars= user: req.user
      res.render('index', vars)

    app.get '/partials/guess', (req, res) ->
      res.render('partials/guess')

    # Landingpage route
    app.get '/landingpage', (req, res) -> 
      res.render('landingpage')

    app.get '/logout', (req, res) ->
      req.logOut()
      res.redirect('/')