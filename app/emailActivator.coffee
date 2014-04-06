Mandrill = require 'mandrill-api/mandrill'

email_message =
  html: "<p>Thanks for your registration!<br/><br/><em>Your BitBetWin Team</em></p>"
  text: "Thanks for your interest! Your BitBetWin Team"
  subject: "bitbetwin-activation"
  from_email: "beta@bitbetwin.co"
  from_name: "bitbetwin.co"

class exports.EmailActivator
  send: (user, callback) ->
    # Send confirmation mail to subscriber
    m = new Mandrill.Mandrill(process.env.MANDRILL_APIKEY)

    email_message.to = [
      "email": user.email
    ]

    html = "Thanks for your registration! Please click the following link" + 
    "in order to activate your account : " + 
    "<a href=localhost:8080/activate?token=#{user.token}>Click here to activate your account.</a>"  +
    "or copy the following url: "  + 
    "localhost:8080/activate?token=#{user.token}"
    email_message.html = html

    m.messages.send 
      "message": email_message
      "async": false
      (results) ->
        callback()
      (e) ->
        console.log "a mandrill error occurred: #{e.name} - #{e.message}"
        callback(e)
