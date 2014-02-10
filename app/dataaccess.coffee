restful = require 'node-restful'
mongoose = restful.mongoose

GameDao = require './dao/gamedao'
CreditDao = require './dao/creditdao'

class DataAccess

  @init: (@io) ->
    @loadConfig()
    GameDao.init @io
    CreditDao.init @io

  @logger: () ->
    @io.log

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

  @startup: () ->
    console.log "connecting to " + @loadConfig().db_address
    mongoose.connect @loadConfig().db_address, (error) ->
      console.log "could not connect because: " + error if error
    db = mongoose.connection

    db.on 'error', console.error.bind(console, 'Mongo DB connection error:')

    db.once 'open', (callback) ->
      console.log "connected with mongodb"

  @shutdown: () ->
      mongoose.disconnect()

module.exports = DataAccess