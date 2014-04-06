should = require "should"
DataAccess = require "../app/dataaccess"

describe "Blockchain", ->

  before (done) ->
    process.env.NODE_ENV = "testing"
    DataAccess.loadConfig()
    PaymentAPI = require("../app/btc/paymentAPI")
    @blockchainWallet = PaymentAPI.getInstance()
    done()

  it 'tests blockchain api', (done) ->
    console.log "running test"
    @blockchainWallet.list (err, data) ->
      addresses = data.addresses 
      addresses.should.be.instanceof(Array)
      adress= addresses[0]
      adress.should.have.property('balance')
      balance = adress.balance
      balance.should.be.equal(1400938800)
      #TODO verify result
      done()