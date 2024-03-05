object false

node( :status ) { 'success' }

child @shops => :shops do
  collection @shops, object_root: false
  extends 'v1/shops/shop'
end
