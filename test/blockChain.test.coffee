should = require "should"

describe "Blockchain", ->

  before (done) ->
    BlockchainWallet = require('../app/btc/blockchainWallet').BlockchainWallet
    @blockchainWallet = new BlockchainWallet
    @blockchainWallet.init()
    done()

#  it 'tests blockchain api', (done) ->
#    @blockchainWallet.list (err, data) ->
#      throw err  if err
#      #TODO verify result
#      done()

#  it 'tests blockchain create wallet', (done) ->
#    data =
#      label : 'testWallet'
#    @blockchainWallet.newAddress data, (err, data) ->
#      throw err  if err
#      #TODO verify result
#      done()