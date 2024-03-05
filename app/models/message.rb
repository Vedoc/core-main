class Message
  include Mongoid::Document
  store_in collection: ENV[ 'MONGO_COLLECTION' ]

  field :offer_id
  field :service_request_id
end
