object false

node( :status ) { 'success' }

child( @vehicle ) do | vehicle |
  extends 'v1/vehicles/vehicle', object: vehicle
end
