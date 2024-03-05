object false

node( :status ) { 'error' }

extends 'v1/shared/resource_errors', locals: { resource: @service_request }

child( @service_request ) do | service_request |
  extends 'v1/service_requests/service_request', object: service_request
end
