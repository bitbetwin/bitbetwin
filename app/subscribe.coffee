Subscriber = require './models/subscriber'

class exports.Subscribe
	init: (app) ->
		app.put '/subscribe/:email', (req, res) ->
			email = req.params.email

			# Check for existing subscribers
			Subscriber.find { email: email }, (err, docs) ->
				console.log "found subscriber: #{docs}"

			@subscriber = new Subscriber
				email: email
			
			@subscriber.save (err) ->
				console.log "#{email} subscribed" unless err
				res.format
					json: ->
						res.json err