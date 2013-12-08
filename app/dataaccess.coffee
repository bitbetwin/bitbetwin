restful = require 'node-restful'
mongoose = restful.mongoose

User = require './models/user'

class DataAccess

	@startup: (config) ->
		mongoose.connect config.db_address, (error) ->
	      console.log "could not connect because: " + error if error
	    db = mongoose.connection

	    db.on 'error', console.error.bind(console, 'Mongo DB connection error:')
	    
	    db.once 'open', (callback) ->
	      console.log "connected with mongodb"
	      
	    #create a user a new user    
	    testUser = new User email: "user", password: "password"
	    User.findOne email: testUser.email , (err, user) ->
	        console.log "no user found, creating new user" if err
	        throw err if err
	        if !user? 
	          testUser.save (err) -> 
	            console.log "user saved" unless err            
	            throw err if err          
	            # fetch user and test password verification

	@shutdown: () ->
    	mongoose.disconnect()

module.exports = DataAccess