Subscriber = require './models/subscriber'
Mandrill = require 'mandrill-api/mandrill'

email_message =
	html: "<p>Thanks for your interest!<br/><br/><em>Your Team Awesome</em></p>"
	text: "Thanks for your interest! Your Team Awesome"
	subject: "Bangman"
	from_email: "no-reply@example.com"
	from_name: "Team Awesome"

class exports.Subscribe
	init: (app) ->
		app.put '/subscribe/:email', (req, res) ->
			email = req.params.email

			# Check for existing subscribers
			Subscriber.find { email: email }, (err, docs) ->
				# console.log "found subscriber: #{docs}"
				if docs.length == 0

					# Save subscriber into MongoDB
					@subscriber = new Subscriber
						email: email
					
					@subscriber.save (err) ->
						console.log "#{email} subscribed" unless err
						console.log "err #{err}"
						res.format
							json: ->
								res.json err

					# Send confirmation mail to subscriber
					m = new Mandrill.Mandrill(process.env.MANDRILL_APIKEY)
					email_message.to = [
						"email": email
					]

					m.messages.send
						"message": email_message
						"async": true
						(results) ->
							console.log "Mandrill result: #{JSON.stringify results}"
						(e) ->
							console.log "a mandrill error occurred: #{e.name} - #{e.message}"
				else
					console.log "#{email} already subscribed"
