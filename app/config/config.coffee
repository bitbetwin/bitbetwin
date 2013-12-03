module.exports =
  development:
    db: "mongodb://localhost/bangman"
    app:
      name: "Bangman -- Dev"
    debug: true

  production:
    db: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL
    app:
      name: "Just Banging arround"
    debug: false
