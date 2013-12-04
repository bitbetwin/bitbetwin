restful = require 'node-restful'
mongoose = restful.mongoose
Schema = mongoose.Schema;

SubscriberScheme = new Schema(
	email: String
)

Subscriber = mongoose.model('Subscriber', SubscriberScheme)
module.exports = Subscriber