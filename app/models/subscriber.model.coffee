module.exports = (sequelize, DataTypes) ->
  Subscriber = sequelize.define "Subscriber",
    email: DataTypes.STRING
    name: DataTypes.STRING
    has_newsletter: DataTypes.BOOLEAN
    confirmation_sent: DataTypes.BOOLEAN
  Subscriber