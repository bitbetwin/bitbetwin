module.exports = (sequelize, DataTypes) ->
  Game = sequelize.define("Game",
    name: DataTypes.STRING
    phrasegenerator: DataTypes.STRING
    durationcalculator: DataTypes.STRING
  ,
    associate: (models) ->
      Game.hasMany models.Credit
      return
  )
  Game