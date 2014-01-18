restful = require 'node-restful'
mongoose = restful.mongoose
Schema = mongoose.Schema;

GameScheme = new Schema(
  name: String
  phrasegenerator: String
  durationcalculator: String
)

Game = mongoose.model('Game', GameScheme)
module.exports = Game