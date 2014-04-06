GameDao = require './dao/gamedao'
CreditDao = require './dao/creditdao'
fs = require("fs")
path = require("path")
Sequelize = require("sequelize")

class DataAccess

  @init: (@io) ->
    @loadConfig()

  @loadConfig: () ->
    return @config if @config?
    
    #settings
    switch process.env.NODE_ENV
      when "development" 
        @env = "development"
      when "production"
        @env = "production"
      when "testing"
        @env = "testing" 
      else
        @env = "development"

    console.log @env + " mode started."

    @config = require("./config/config")[@env]

  @isInTestingMode: () ->
    return @env == 'testing'

  @isInDevMode: () ->
    return @env == 'testing' || @env == 'development'

  @startup: (callback) ->
    if @db?
      console.log "already connected to " + @loadConfig().dbname
      callback null, @db
      return

    console.log "connecting to " + @loadConfig().dbname
    sequelize = new Sequelize(@loadConfig().dbname, @loadConfig().username, @loadConfig().password, {
        dialect: "mysql",
        port: @loadConfig().port,
        host: @loadConfig().host,
        multipleStatements: true,
      })

    @db = {}

    dirname = __dirname + "/models/"
    fs.readdirSync(dirname).filter((file) =>
      (file.indexOf(".") isnt 0) and (file.slice(-13) is ".model.coffee")
    ).forEach (file) =>
      model = sequelize.import(path.join(dirname, file))
      @db[model.name] = model
      return

    Object.keys(@db).forEach (modelName) =>
      @db[modelName].options.associate @db  if @db[modelName].options.hasOwnProperty("associate")
      return

    @db.sequelize = sequelize

    sequelize.sync( force: false ).complete (err) =>
      GameDao.init @io

      CreditDao = require('./dao/creditdao')
      CreditDao.init @io
      callback err, @db if callback

  @shutdown: () ->

  @logger: () ->
    @io.log

module.exports = DataAccess