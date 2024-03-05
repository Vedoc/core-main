attributes :id, :summary, :evacuation, :repair_parts, :vin, :radius, :title,
           :mileage, :address, :estimated_budget

node( :distance, &:distance_in_miles )
node( :category, &:category_before_type_cast )
node( :status ) { | request | request.status_before_type_cast.to_i }
node( :location, &:pretty_location )
node( :schedule_service ) { | request | I18n.l( request.schedule_service ) if request.schedule_service }
node( :pictures ) { | request | request.pictures.map { | p | p.data.url } }
child( :vehicle ) do | vehicle |
  extends 'v1/vehicles/vehicle', object: vehicle
end

if @current_account.business_owner?
  node( :phone ) { | request | request.client.phone }

  child offers: :offer do | offers |
    object false
    extends 'v1/offers/offer', object: offers.find_by( shop: @current_account.accountable )
  end
  node( :offer, if: ->( request ) { request.offers.blank? } ) { nil }
else
  child :offers, object_root: false do
    extends 'v1/offers/offer_client'
  end
  node( :offers, if: ->( request ) { request.offers.blank? } ) { [] }
end
