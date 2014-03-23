module.exports =
  development:
    dbname: "bitbetwindb"
    username: "root"
    password: "password"
    host: "localhost"
    port: 3306
    app:
      name: "BitBetWin -- Dev"
    debug: true

  testing:
    dbname: "bitbetwinTest"
    username: "root"
    password: "password"
    host: "localhost"
    port: 3306
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
