object false

node( :status ) { 'success' }

child( @rating ) do | _rating |
  attributes :score, :offer_id
end
