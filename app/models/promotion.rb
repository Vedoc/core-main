class Promotion < ApplicationRecord
    validates :first_name, :last_name, :email, :phone_number, :car_needs, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  end
  