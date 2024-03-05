object false

child locals[ :accountable ] => :shop do
  attributes :name, :hours_of_operation, :techs_per_shift, :certified, :lounge_area,
             :supervisor_permanently, :languages, :complimentary_inspection, :address,
             :tow_track, :vehicle_diesel, :vehicle_electric, :vehicle_warranties,
             :categories, :phone, :owner_name, :additional_info

  node( :average_rating ) { | shop | shop.average_rating.to_f }
  node( :location, &:pretty_location )
  node( :avatar ) { | shop | shop.avatar.url }
  node( :pictures ) do | shop |
    shop.pictures.map { | p | { url: p.data.url, id: p.id } }
  end

  if @current_account&.client?
    node( :distance ) do | shop |
      @current_account.accountable.location ? shop.distance_in_miles : nil
    end
  end
end
