module.exports =
  development:
    db_address: "mongodb://localhost/bitbetwindb"
    app:
      name: "BitBetWin -- Dev"
    debug: true

  testing:
    db_address: "mongodb://localhost/bitbetwinTest"
    app:
      name: "BitBetWin -- Test"
    debug: true

  production:
    db: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://localhost/bitbetwindb"
    db_address: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://localhost/bitbetwindb"
    google_alaytics_id: "UA-47266449-1"
    app:
      name: "BitBetWin"
    debug: false
    mode:process.env.MODE
