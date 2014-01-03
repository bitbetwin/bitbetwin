restful = require 'node-restful'
mongoose = restful.mongoose

User = require './models/user'

class DataAccess

	@init: (@io) ->
		Game = require('./hangman/game').Game
		game1 = new Game io, 'game1'
		game1.start()
		game2 = new Game io, 'game2'
		game2.start()

		@logger().info "initialised games"

		#TODO: move games to db
		@commands = new Array()
		@commands['game1'] = new Array()
		@commands['game1']['instance'] = game1
		@commands['game1']['functions'] = ['join', 'leave', 'guess', 'report']
		@commands['game2'] = new Array()
		@commands['game2']['instance'] = game2
		@commands['game2']['functions'] = ['join', 'leave', 'guess', 'report']

		@loadConfig()

	@retrieveGames: () ->
		#TODO: move to db
		return { games: [ {name: 'game1' }, {name: 'game2'}] }

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