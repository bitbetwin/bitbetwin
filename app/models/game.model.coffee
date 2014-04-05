module.exports = (sequelize, DataTypes) ->
  Game = sequelize.define("Game",
    name: DataTypes.STRING
    phrasegenerator: DataTypes.STRING
    durationcalculator: DataTypes.STRING
  ,
    associate: (models) ->
      Game.hasMany models.Credit, { foreignKey: 'game' , foreignKeyConstraint:false }
      return
  )
  Game