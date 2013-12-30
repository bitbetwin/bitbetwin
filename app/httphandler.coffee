class exports.HttpHandler
  init: (app) ->
    app.get '/', (req, res) ->
      vars = 
        user: req.user
        info: req.flash('info') 
        error: req.flash('error') 
      res.render('index', vars)

    app.get '/partials/guess', (req, res) ->
      res.render('partials/guess')

    app.get '/partials/report', (req, res) ->
      res.render('partials/report')

    # Landingpage route
    app.get '/landingpage', (req, res) -> 
      res.render('landingpage')

    app.get '/logout', (req, res) ->
      req.logOut()
      res.redirect('/')
