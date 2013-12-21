should = require "should"

describe "Blockchain", ->

  before (done) ->
    BlockchainWallet = require('../app/blockchainWallet').BlockchainWallet
    guid = process.env.bitchainAdress
    pass1= process.env.bitchain1
    pass2= process.env.bitchain2
    @blockchainWallet = new BlockchainWallet
    @blockchainWallet.init guid, pass1, pass2
    done()

  it 'tests blockchain api', (done) ->
    @blockchainWallet.list (err, data) ->
      throw err  if err
      #TODO verify result
      done()

  it 'tests blockchain create wallet', (done) ->
    data =
      label : 'testWallet'
    @blockchainWallet.newAddress data, (err, data) ->
      throw err  if err
      #TODO verify result
      done()