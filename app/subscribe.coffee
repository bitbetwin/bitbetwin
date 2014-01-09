Subscriber = require './models/subscriber'
Mandrill = require 'mandrill-api/mandrill'
Validator = require 'email-validator'

email_message =
  html: "<p>Thanks for your interest!<br/><br/><em>Your Team Awesome</em></p>"
  text: "Thanks for your interest! Your Team Awesome"
  subject: "Bangman"
  from_email: "no-reply@example.com"
  from_name: "Team Awesome"

class exports.Subscribe
  init: (app) ->
    app.put '/subscribe', (req, res) ->

      email = req.body.email
      name = req.body.name

      ret =
        err: false
        msg: null
        validation:
          name: null
          email: null

      # console.log "PUT: name=#{name}, email=#{email}"

      if !email? or !name? or !Validator.validate(email)
        res.send(500);
        return

      # Check for existing subscribers
      Subscriber.find { email: email }, (err, docs) ->
        # console.log "found subscriber: #{docs}"
        if docs.length == 0

          # Save subscriber into MongoDB
          s = new Subscriber
            email: email
            name: name
          
          s.save (err) ->
            if err
              ret.err = true
              ret.msg = "Sorry, an error occured. Please try again later."
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
          ret.err = true
          ret.msg = "You are already subscribed!"
          res.format
            json: ->
              res.json ret
