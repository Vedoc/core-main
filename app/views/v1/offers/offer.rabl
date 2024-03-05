attributes :id, :budget, :description, :accepted
node( :pictures ) do | offer |
  offer.pictures.map { | p | { url: p.data.url, id: p.id } }
end
