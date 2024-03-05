object false

node( :status ) { 'success' }

child @model_years => :model_years do
  collection @model_years, object_root: false
  attributes :id, :year
end
