restful = require 'node-restful'
mongoose = restful.mongoose
Schema = mongoose.Schema;

UserSchema = new Schema(
  email: String
  password: String
  salt: String
  hash: String
)

User = mongoose.model("User", UserSchema)
module.exports = User