restful = require 'node-restful'
mongoose = restful.mongoose
Schema = mongoose.Schema
bcrypt = require 'bcrypt'
async = require "async"


SALT_WORK_FACTOR = 10

UserSchema = new Schema(
  email: String
  token: String
  password: String
  salt: String
  hash: String
  btc_id: String
  activated: 
      type: Boolean
      default: false
)
UserSchema.pre "save", (next) ->
  user = this
  
  # only hash the password if it has been modified (or is new)
  return next() unless user.isModified("password")
  
  async.waterfall [(callback) ->
    # generate a salt
    bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) ->  
      return next(err)  if err
      callback null, salt
  , (salt, callback) ->
    # hash the password along with our new salt
    bcrypt.hash user.password, salt, (err, hash) ->
      return next(err)  if err
      user.password = hash
      callback null, salt
  , (salt, callback) ->
    #generate the registration token
    bcrypt.hash user.email, salt, (err, hash) ->    
      return next(err)  if err  
      #assign token to user
      user.token = hash       
      callback()
  ], next

UserSchema.methods.comparePassword = (candidatePassword, cb) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    return cb(err)  if err
    cb null, isMatch

User = mongoose.model("User", UserSchema)
module.exports = User