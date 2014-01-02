restful = require 'node-restful'
mongoose = restful.mongoose

User = require './models/user'

class DataAccess

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
		mongoose.connect @loadConfig().db_address, (error) ->
		  console.log "could not connect because: " + error if error
		db = mongoose.connection

		db.on 'error', console.error.bind(console, 'Mongo DB connection error:')

		db.once 'open', (callback) ->
		  console.log "connected with mongodb"

		#TODO 
		#create a user a new user    
		testUser = new User email: "user", password: "password"
		testUser.activated=true
		User.findOne email: testUser.email , (err, user) ->
		    console.log "no user found, creating new user" unless user
		    throw err if err
		    if !user? 
		      testUser.save (err) -> 
		        console.log "user saved" unless err            
		        throw err if err          
		        # fetch user and test password verification

	@shutdown: () ->
    	mongoose.disconnect()

module.exports = DataAccess