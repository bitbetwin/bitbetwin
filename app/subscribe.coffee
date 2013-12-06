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

			ret =
				err: false
				msg: ""

			# Check for existing subscribers
			Subscriber.find { email: email }, (err, docs) ->
				# console.log "found subscriber: #{docs}"
				if docs.length == 0

					# Save subscriber into MongoDB
					s = new Subscriber
						email: email
					
					s.save (err) ->
						if err
							ret.err = true
							ret.msg = "Sorry, we an error occured. Please try again later."
							console.warn err.message
						else
							ret.msg = "You are now subscribed and should receive a confirmation mail soon."
							console.log "#{email} subscribed" unless err

						res.format
							json: ->
								res.json ret

					# Send confirmation mail to subscriber
					m = new Mandrill.Mandrill(process.env.MANDRILL_APIKEY)
					email_message.to = [
						"email": email
					]

					m.messages.send
						"message": email_message
						"async": false
						(results) ->
							console.log "Mandrill result: #{JSON.stringify results}"
							if (results[0].sent == "sent")
								s.confrimation_sent = yes
								s.update
						(e) ->
							console.warn "a mandrill error occurred: #{e.name} - #{e.message}"
				else
					console.log "#{email} already subscribed"
					ret.msg = "You are already subscribed!"
					res.format
						json: ->
							res.json ret
