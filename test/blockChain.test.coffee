should = require "should"



describe "Blockchain", ->

  before (done) ->
    console.log " got here"
    BlockchainWallet = require('../app/blockchainWallet').BlockchainWallet
    guid = process.env.bitchainAdress
    pass1= process.env.bitchain1
    pass2= process.env.bitchain2
    console.log "asdasdasd" + BlockchainWallet
    @blockchainWallet = new BlockchainWallet
    @blockchainWallet.init guid, pass1, pass2
    done()

  it 'tests a guess with multiple matches', (done) ->
    @blockchainWallet.list (err, data) ->
      throw err  if err
      console.log data
      done()