object false

node( :status ) { 'success' }

child( @resource ) do | account |
  attributes :id, :name, :accountable_type, :accountable_id

  node( :avatar ) { account.accountable.avatar.url }
end
