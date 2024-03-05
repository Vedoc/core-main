object false

node( :status ) { 'success' }

child @car_makes => :car_makes do
  collection @car_makes, object_root: false
  attributes :id, :name
end
