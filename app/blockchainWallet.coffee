request = require("request")
querystring = require("querystring")

class exports.BlockchainWallet

  init: (@guid, @mainPassword, @secondPassword) ->
    @url = "https://blockchain.info/merchant/"

  makeRequest : (method, secondPasswordApplicable, params, callback) ->
    params.password = @mainPassword
    params.second_password = @secondPassword  if secondPasswordApplicable and @secondPassword
    queryString = querystring.stringify(params)
    url = @url + @guid + "/" + method + "?" + queryString
    request url, (err, response, body) ->
      if err or response.statusCode isnt 200
        callback (if err then err else response.statusCode)
        return
      result = JSON.parse(body)
      if result.error
        callback result.error
        return
      callback null, result


  balance : (callback) ->
    @makeRequest "balance", false, {}, callback

  list : (callback) ->
    @makeRequest "list", false, {}, callback

  addressBalance : (address, confirmations, callback) ->
    @makeRequest "address_balance", false,
      address: address
      confirmations: confirmations
    , callback

  payment : (to, amount, params, callback) ->
    params.to = to
    params.amount = amount
    @makeRequest "payment", true, params, callback

  sendMany : (recipients, params, callback) ->
    params.recipients = JSON.stringify(recipients)
    @makeRequest "sendmany", true, params, callback

  newAddress : (params, callback) ->
    @makeRequest "new_address", true, params, callback

  archiveAddress : (address, callback) ->
    @makeRequest "archive_address", true,
      address: address
    , callback

  unarchiveAddress : (address, callback) ->
    @makeRequest "unarchive_address", true,
      address: address
    , callback

  autoConsolidate : (days, callback) ->
    @makeRequest "auto_consolidate", true,
      days: days
    , callback
