attributes :id, :name, :address, :phone

node( :average_rating ) { | s | s.average_rating.to_f }
node( :avatar ) { | s | s.avatar.url }
node( :location, &:pretty_location )
node( :distance, &:distance_in_miles )
