mongoose = require("mongoose")
hash = require("../utils/hash")
UserSchema = mongoose.Schema(
  email: String
  salt: String
  hash: String
)
UserSchema.statics.signup = (email, password, done) ->
  User = this
  hash password, (err, salt, hash) ->
    throw err  if err
    
    # if (err) return done(err);
    User.create
      email: email
      salt: salt
      hash: hash
    , (err, user) ->
      throw err  if err
      
      # if (err) return done(err);
      done null, user



UserSchema.statics.isValidUserPassword = (email, password, done) ->
  @findOne 
    email: email
  , (err, user) ->
    
    # if(err) throw err;
    return done(err)  if err
    unless user
      return done(null, false,
        message: "Incorrect email."
      )
    hash password, user.salt, (err, hash) ->
      return done(err)  if err
      return done(null, user)  if hash is user.hash
      done null, false,
        message: "Incorrect password"


User = mongoose.model("User", UserSchema)
module.exports = User