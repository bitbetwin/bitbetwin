DataAccess = require './dataaccess'

class exports.HttpHandler
  init: (app) ->
    # Landingpage route
    switch DataAccess.loadConfig().mode
      when "beta"
        console.log "gog here motho " + DataAccess.loadConfig().mode
        console.log "gogo here 2 " + DataAccess.loadConfig().google_alaytics_id
        app.get '*', (req, res) ->
          res.render('landingpage',
            google_analytics_id: DataAccess.loadConfig().google_alaytics_id)
      else
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
  
        app.get '/logout', (req, res) ->
          req.logOut()
          res.redirect('/')

        app.get '/landingpage', (req, res) ->
          res.render('landingpage',
            google_analytics_id: DataAccess.loadConfig().google_alaytics_id)
