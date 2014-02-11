class exports.SimpleChargeCalculator

  commission: (guess) ->
    if guess.length == 0
      return 0
    1

  pot: (guess) ->
    if guess.length == 0
      return 0
    (guess.length * 2) - (@commission guess)