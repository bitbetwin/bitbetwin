Blockchain = require('./blockchainWallet').BlockchainWallet
MockedWallet = require('./mockedWallet').BlockchainWallet

DataAccess = require('../dataaccess')

module.exports = class PaymentAPI

  @instance=null

  @getInstance:->
    if !@instance
      @instance=@createAPI()
    return @instance

  @createAPI:->
    console.log "create api started"
    if DataAccess.isInDevMode()
      console.log "using debug api"
      wallet = new MockedWallet
    else
      console.log "using blockchain"
      wallet = new Blockchain
      wallet.init()    
    return wallet