Subscriber = require './models/subscriber'
Mandrill = require 'mandrill-api/mandrill'
Validator = require 'email-validator'

email_message =
  html: "Hi [[NAME]]!<br /><br />Thanks for your interest in <a href=\"http://www.bitbetwin.co\">bitbetwin.co</a>!<br />We will notify as soon as we are ready to roll out the beta platform.<br /><br />Best,<br /><em>bitbetwin.co</em>"
  text: "Hi [[NAME]]!\n\nThanks for your interest in http://www.bitbetwin.co!\nWe will notify as soon as we are ready to roll out the beta platform.\n\nBest,\nbitbetwin.co"
  subject: "Bitbetwin.co Beta Registration"
  from_email: "beta@bitbetwin.co"
  from_name: "BTC Games"

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

      if !email? or !name? or !Validator.validate(email)
        res.send(500);
        return

      # Check for existing subscribers
      Subscriber.find { email: email }, (err, docs) ->
        if docs.length == 0

          # Save subscriber into MongoDB
          s = new Subscriber
            email: email
            name: name
          
          s.save (err) ->
            if err
              ret.err = true
              ret.msg = "Sorry, an error occured. Please try again later."
              console.error err.message
            else
              ret.msg = "You are now subscribed and should receive a confirmation mail soon."
              console.info "#{email} subscribed" unless err

            res.format
              json: ->
                res.json ret

          # Send confirmation mail to subscriber
          m = new Mandrill.Mandrill(process.env.MANDRILL_APIKEY)
          email_message.to = [
            "email": email
          ]

          email_message.html = email_message.html.replace "[[NAME]]", name
          email_message.text = email_message.text.replace "[[NAME]]", name

          m.messages.send
            "message": email_message
            "async": false
            (results) ->
              if (results[0].status == "sent")
                Subscriber.update
                  email: results[0].email
                ,
                  "$set": confirmation_sent: yes
                , (err) ->
                  console.error "{results[0].email} could not bet updated: {err}" if err
                console.log "confirmation mail sent to #{results[0].email}"
            (e) ->
              console.error "a mandrill error occurred: #{e.name} - #{e.message}"
        else
          ret.err = true
          ret.msg = "You are already subscribed with this email address!"
          res.format
            json: ->
              res.json ret
