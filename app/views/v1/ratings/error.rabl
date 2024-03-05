object false

node( :status ) { 'error' }

extends 'v1/shared/resource_errors', locals: { resource: @rating }
