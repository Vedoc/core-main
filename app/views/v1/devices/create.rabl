object false

node( :status ) { 'success' }

child( @device ) do | _device |
  attributes :platform, :device_id, :device_token
end
