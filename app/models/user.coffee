restful = require 'node-restful'
mongoose = restful.mongoose
Schema = mongoose.Schema
bcrypt = require 'bcrypt'

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
  return next()  unless user.isModified("password")
  
  # generate a salt
  bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) ->
    return next(err)  if err
    
    # hash the password along with our new salt
    bcrypt.hash user.password, salt, (err, hash) ->
      return next(err)  if err
      
      # override the cleartext password with the hashed one
      user.password = hash

      #generate registration token
      bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) ->
        return next(err)  if err
        bcrypt.hash user.email, salt, (err, hash) ->
          return next(err)  if err
          user.token = hash
          console.log "user token=" + user.token 
          next()

  

UserSchema.methods.comparePassword = (candidatePassword, cb) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    return cb(err)  if err
    cb null, isMatch

User = mongoose.model("User", UserSchema)
module.exports = User