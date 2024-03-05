attributes :id, :make, :model, :year, :category

node( :photo ) { | v | v.photo.url }
