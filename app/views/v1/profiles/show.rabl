object false

node( :status ) { 'success' }

child( @account ) do | account |
  attributes :email

  extends(
    "v1/accountables/#{ account.accountable_type.downcase }",
    locals: { accountable: account.accountable }
  )
end
