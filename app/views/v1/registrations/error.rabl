object false

node( :status ) { 'error' }

extends 'v1/shared/resource_errors', locals: { resource: @resource }

child( @resource ) do
  attributes :email, :zip_code, :phone, :employee

  if @resource.accountable_type
    extends(
      "v1/accountables/#{ @resource.accountable_type.downcase }",
      locals: { accountable: @resource.accountable }
    )
  end
end
