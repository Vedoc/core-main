object false

child locals[:accountable] => :client do
  attributes :name, :phone, :address

  # Handle avatar being nil
  node(:avatar) { |c| c.avatar.present? ? c.avatar.url : "" }
  node(:location, &:pretty_location)

  child :vehicles do
    collection @vehicles, object_root: false
    extends 'v1/vehicles/vehicle'
  end
end
