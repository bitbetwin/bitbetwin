DataAccess = require './dataaccess'

class exports.HttpHandler
  init: (app) ->
    app.get '/', (req, res) ->
      vars = 
        user: req.user
        info: req.flash('info') 
        error: req.flash('error') 
      res.render('index', vars)

    app.get '/partials/guess', (req, res) ->
      res.render('partials/guess',
        user: req.user)

    app.get '/partials/report', (req, res) ->
      res.render('partials/report',
        user: req.user)

    # Landingpage route
    app.get '/landingpage', (req, res) ->
      res.render('landingpage',
        google_analytics_id: DataAccess.loadConfig().google_alaytics_id)

    app.get '/logout', (req, res) ->
      req.logOut()
      res.redirect('/')
