module.exports =
  development:
    db_address: "mongodb://localhost/bangmandb"
    app:
      name: "Bangman -- Dev"
    debug: true

  production:
    db: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL
    db_address: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL
    app:
      name: "Just Banging arround"
    debug: false
