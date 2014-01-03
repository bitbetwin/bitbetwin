restful = require 'node-restful'
mongoose = restful.mongoose
Schema = mongoose.Schema;

SubscriberScheme = new Schema(
  name: String
	email: String
  confirmation_sent:
    type: Boolean
    default: no
)

Subscriber = mongoose.model('Subscriber', SubscriberScheme)
module.exports = Subscriber