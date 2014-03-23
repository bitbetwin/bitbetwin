module.exports = (sequelize, DataTypes) ->
  Credit = sequelize.define("Credit",
    value: DataTypes.INTEGER
  ,
    associate: (models) ->
      Credit.belongsTo models.User
      Credit.belongsTo models.Game
      return
  )
  Credit