bcrypt = require 'bcrypt'
async = require "async"

SALT_WORK_FACTOR = 10

module.exports = (sequelize, DataTypes) ->
  User = sequelize.define "User",
    email: DataTypes.STRING
    username: DataTypes.STRING
    token: DataTypes.STRING
    password: DataTypes.STRING
    salt: DataTypes.STRING
    hash: DataTypes.STRING
    activated: 
      type: DataTypes.BOOLEAN
      default: false
  ,
    paranoid: true
    instanceMethods: 
      comparePassword: (candidatePassword, cb) ->
        bcrypt.compare candidatePassword, @password, (err, isMatch) ->
          return cb(err)  if err
          cb null, isMatch
  ,
    associate: (models) ->
      User.hasMany models.Credit, { foreignKey: 'owner' , foreignKeyConstraint:true }
      return

  User.hook 'beforeCreate', (user, fn) ->
    async.parallel [
      (callback)->
        async.waterfall [(callback) ->
          # generate a salt
          bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) ->  
            return fn(err)  if err
            callback null, salt
        , (salt, callback) ->
          # hash the password along with our new salt
          bcrypt.hash user.password, salt, (err, hash) ->
            return fn(err)  if err
            user.password = hash
            callback null, salt
        , (salt, callback) ->
          #generate the registration token
          bcrypt.hash user.email, salt, (err, hash) ->    
            return fn(err)  if err  
            #assign token to user
            user.token = hash
            callback()
        ], callback
      (callback)->
        #btc stuff
        callback()
    ], fn

  User