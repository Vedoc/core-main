object false

node( :status ) { 'success' }

child( @offer ) do | offer |
  extends 'v1/offers/offer', object: offer
end
