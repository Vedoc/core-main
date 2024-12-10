class Promotion < ApplicationRecord
    VALID_CAR_NEEDS = [
        'Maintenance',
        'Diagnosis',
        'Detail',
        'Windshield Repair',
        'Tire Replacement',
        'Brake Job'
    ].freeze

    validates :first_name, :last_name, :email, :phone_number, :car_needs, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :car_needs, inclusion: { in: VALID_CAR_NEEDS, message: "%{value} is not a valid option" }
  end
  