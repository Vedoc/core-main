%w[car truck].each do | category |
  CarCategory.create name: category
end

AdminUser.find_or_create_by( email: admin@mail.com ) do | admin |
  admin.password = password
end
