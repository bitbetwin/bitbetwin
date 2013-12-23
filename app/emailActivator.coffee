Subscriber = require './models/subscriber'
Mandrill = require 'mandrill-api/mandrill'

email_message =
  html: "<p>Thanks for your registration!<br/><br/><em>Your Team Awesome</em></p>"
  text: "Thanks for your interest! Your Team Awesome"
  subject: "Bangman-activation"
  from_email: "no-reply@example.com"
  from_name: "Team Awesome"

class exports.EmailActivator
  send: (user) ->
    # Send confirmation mail to subscriber
    m = new Mandrill.Mandrill(process.env.MANDRILL_APIKEY)

    email_message.to = [
      "email": user.email
    ]

    email_message.text = "Thanks for your registration! Please click the following link"+
    "in order to activate your account : "+
    "<a href=localhost:8080/activate?token=#{user.token}>Click here to activate your account.</a>" + 
    "or copy the following url: " + 
    "localhost:8080/activate?token=#{user.token}"

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
