object false

node( :status ) { 'success' }

child( @service_request ) do | service_request |
  extends 'v1/service_requests/service_request', object: service_request
end
