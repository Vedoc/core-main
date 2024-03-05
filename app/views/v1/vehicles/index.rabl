object false

node( :status ) { 'success' }

child @vehicles => :vehicles do
  collection @vehicles, object_root: false
  extends 'v1/vehicles/vehicle'
end
