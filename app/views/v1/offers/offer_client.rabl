attributes :id, :budget, :description, :shop_id, :accepted

node( :name ) { | offer | offer.shop.name }
node( :avatar ) { | offer | offer.shop.avatar.url }
node( :address ) { | offer | offer.shop.address }
node( :pictures ) do | offer |
  offer.pictures.map { | p | { url: p.data.url, id: p.id } }
end
