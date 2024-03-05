object false

node( :status ) { 'success' }

child( @resource ) do | account |
  attributes :email, :employee

  extends(
    "v1/accountables/#{ account.accountable_type.downcase }",
    locals: { accountable: account.accountable }
  )
end

extends 'v1/accountables/auth'
