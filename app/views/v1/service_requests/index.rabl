object false

node( :status ) { 'success' }

child @service_requests => :service_requests do
  collection @service_requests, object_root: false

  attributes :id, :summary, :title, :estimated_budget, :address

  node( :distance, &:distance_in_miles )
  node( :category, &:category_before_type_cast )
  node( :status, &:status_before_type_cast )
  node( :schedule_service ) { | request | I18n.l( request.schedule_service ) if request.schedule_service }
  node( :location, &:pretty_location )
  node( :pictures ) { | request | request.pictures.map { | p | p.data.url } }
  child( :vehicle ) do | vehicle |
    extends 'v1/vehicles/vehicle', object: vehicle
  end

  node( :phone ) { | request | request.client.phone } if @current_account.business_owner?
end
