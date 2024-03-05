object false

child @recepient => :recepient do | recepient |
  attributes :name
  node( :avatar ) { recepient.avatar.url }
  node( :accountable_id ) { recepient.id }
  node( :accountable_type ) { recepient.class.name }

  child @offer => :offer do
    attributes :id, :service_request_id
  end
end
