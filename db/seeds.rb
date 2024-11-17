# Seed default CarCategories
%w[car truck].each do |category|
  CarCategory.find_or_create_by!(name: category)
end

puts "Default CarCategories seeded successfully."


# AdminUser.find_or_create_by(email: 'admin@mail.com') do |admin|
#   admin.password = 'password'
# end

# AdminUser.find_or_create_by( email: ENV[ 'ADMIN_EMAIL' ] ) do | admin |
#   admin.password = ENV[ 'ADMIN_PASSWORD' ]
# end

# Setting.create(var: 'password_reset_duration', value: '3600')

# Setting.find_or_create_by(var: 'password_reset_duration') do |setting|
#   setting.value = '3600'
# end
# db/seeds.rb
# Setting.create(var: 'password_reset_duration', value: '24')

