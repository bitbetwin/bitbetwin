restful = require 'node-restful'
mongoose = restful.mongoose

Credit = require '../models/credit'
User = require '../models/user'
Promise = require 'promise'

class CreditDao

  @init: (@io) ->

  @retrieveCredits: (userid, callback) ->
    Credit.find owner: userid, game: null, (err, credits) ->
      callback err, credits

  @retrievePot: (gameid, callback) ->
    Credit.find game: gameid, (err, credits) ->
      return callback err if err
      callback err, credits

  @drawCommission: (credit, callback) ->
    User.findOne email: "mail@bitbetwin.co", (err, bank) ->
      return callback err if err
      credit.game = null
      credit.owner = bank._id
      credit.save (err) ->
        callback err

  @chargeCredits: (userid, gameid, pot, commission, callback) ->
    bet = pot + commission
    if bet < 0
      callback "Too small bet"

    return callback() if bet == 0

    CreditDao.retrieveCredits userid, (err, credits) ->
      return callback err if err

      if credits.length < (pot + commission)
        return callback "Not enough credits"

      promises = []
      for credit in credits when credits.indexOf(credit) < pot
        credit.game = gameid
        promises.push credit.save (err) ->
          return callback err if err

      for credit in credits when credits.indexOf(credit) >= pot && credits.indexOf(credit) < (pot + commission)
        promises.push CreditDao.drawCommission credit, (err) ->
          return callback err if err

      Promise.all( promises ).then () ->
        console.log "finished charging"
        callback null

  @payWinners: (winners, gameid, callback) ->
    @retrievePot gameid, (err, credits) ->
      return callback err if err

      if credits.length < winners.length
        return callback "Less credits than winners is not possible."

      share = Math.floor(credits.length / winners.length)

      promises = []

      # split credits by equal shares
      index = -1
      winnum = 0
      for winner in winners
        deal = 0
        while deal < share
          index = winnum + deal
          console.log credits[index]._id + ", index: " + index + " -> " + winner._id
          credits[index].owner = winner._id
          credits[index].game = null
          promises.push credits[index].save (err) ->
            throw err if err
          deal++
        winnum += share

      # handle remaining credits, which could not be split equally.
      # for now we just move them to the bank
      for credit in credits when credits.indexOf(credit) > index
          promises.push CreditDao.drawCommission credit, (err) ->
            throw err if err

      Promise.all( promises ).then () ->
        callback()

  @logger: () ->
    @io.log

module.exports = CreditDao