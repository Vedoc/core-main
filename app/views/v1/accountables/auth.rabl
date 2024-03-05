child :auth do
  node( 'access-token' ) { @token }
  node( 'client' ) { @client_id }
  node( 'token-type' ) { 'Bearer' }
  node( 'uid' ) { @resource.uid }
end
