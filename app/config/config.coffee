module.exports =
  development:
    db_address: "mongodb://localhost/bangmandb"
    app:
      name: "Bangman -- Dev"
    debug: true

  testing:
    db_address: "mongodb://localhost/bangmandbTest"
    app:
      name: "Bangman -- Test"
    debug: true

  production:
    db: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://localhost/bangmandb"
    db_address: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://localhost/bangmandb"
    google_alaytics_id: "UA-47266449-1"
    app:
      name: "BitBetWin"
    debug: false
    mode:process.env.MODE
