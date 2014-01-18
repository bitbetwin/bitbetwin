restful = require 'node-restful'
mongoose = restful.mongoose
Schema = mongoose.Schema;

CreditScheme = new Schema(
  owner: { type: Schema.Types.ObjectId, ref: 'User', required: true }
  value: { type: Number, required: true }
)

Credit = mongoose.model('Credit', CreditScheme)
module.exports = Credit