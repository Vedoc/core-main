object false

node( :status ) { 'success' }

child @car_models => :car_models do
  collection @car_models, object_root: false
  attributes :id, :name
end
