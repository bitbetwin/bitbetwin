Promise = require 'promise'

DataAccess = require '../dataaccess'

class CreditDao

  @init: (@io) ->

  @retrieveCredits: (userid, callback) ->
    DataAccess = require '../dataaccess'
    DataAccess.db.Credit.findAll(where: UserId: userid, GameId: null).complete (err, credits) ->
      callback err, credits

  @retrievePot: (gameid, callback) ->
    DataAccess.db.Credit.findAll(where: GameId: gameid).complete (err, credits) ->
      return callback err if err
      callback err, credits

  @drawCommission: (credit, callback) ->
    DataAccess.db.User.find(where: email: "mail@bitbetwin.co").complete (err, bank) ->
      return callback err if err
      if !bank?
        return callback "Cannot draw commission: Reason: Missing bank user!"
      credit.GameId = null
      credit.UserId = bank.id
      credit.save().complete (err) ->
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
        credit.GameId = gameid
        promises.push credit.save().complete (err) ->
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

      if !credits? && winners.length == 0
        return callback null

      if !credits? || credits.length < winners.length
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
          console.log credits[index].id + ", index: " + index + " -> " + winner.id
          credits[index].UserId = winner.id
          credits[index].GameId = null
          promises.push credits[index].save().complete (err) ->
            throw err if err
          deal++
        winnum += share

      # handle remaining credits, which could not be split equally.
      # for now we just move them to the bank
      for credit in credits when credits.indexOf(credit) > index
          promises.push CreditDao.drawCommission credit, (err) ->
            throw err if err

      Promise.all( promises ).then () ->
        callback null, share

  @logger: () ->
    @io.log

module.exports = CreditDao