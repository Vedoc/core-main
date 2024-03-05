object false

node( :status ) { 'success' }

if @resource.client? || @promo_code.present?
  child( @resource ) do | account |
    attributes :email, :employee

    extends(
      "v1/accountables/#{ account.accountable_type.downcase }",
      locals: { accountable: account.accountable }
    )
  end

  extends 'v1/accountables/auth'
end
