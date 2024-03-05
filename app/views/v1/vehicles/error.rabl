object false

node( :status ) { 'error' }

extends 'v1/shared/resource_errors', locals: { resource: @vehicle }

child( @vehicle ) do | vehicle |
  extends 'v1/vehicles/vehicle', object: vehicle
end
