%w[car truck].each do |category|
  CarCategory.create(name: category)
end

# AdminUser.find_or_create_by(email: 'admin@mail.com') do |admin|
#   admin.password = 'password'
# end

AdminUser.find_or_create_by( email: ENV[ 'ADMIN_EMAIL' ] ) do | admin |
  admin.password = ENV[ 'ADMIN_PASSWORD' ]
end
