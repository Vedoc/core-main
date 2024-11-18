object false

node( :status ) { 'success' }

if @resource&.client? || @promo_code&.present?
  child( @resource ) do | account |
    attributes :email, :employee if account.present?

    if account&.accountable_type.present?
      extends(
        "v1/accountables/#{ account.accountable_type.downcase }",
        locals: { accountable: account.accountable }
      )
    end
  end

  extends 'v1/accountables/auth'
end
