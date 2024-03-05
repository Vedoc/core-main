module Docs
  module V1
    module Registrations
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Registration' do
          endpoint '/auth'
          group 'Registrations'
        end
      end

      # Params
      create_params = {
        email: {
          type: :string,
          required: :required,
          description: 'Email'
        },
        password: {
          type: :string,
          required: :required,
          description: 'Password'
        },
        'client[location]': {
          type: :object,
          required: :optional,
          description: 'Clients Location'
        },
        'client[address]': {
          type: :string,
          required: :optional,
          description: 'Clients Address'
        },
        'client[phone]': {
          type: :string,
          required: :optional,
          description: 'Clients Phone'
        },
        'client[name]' => {
          type: :string,
          required: :optional,
          description: 'Client Name'
        },
        'client[avatar]' => {
          type: :file,
          required: :optional,
          description: 'Avatar'
        },
        'shop[name]' => {
          type: :string,
          required: :required,
          description: 'Shop Name'
        },
        'shop[location]': {
          type: :object,
          required: :required,
          description: 'Shops Location'
        },
        'shop[address]': {
          type: :string,
          required: :required,
          description: 'Shops Address'
        },
        'shop[phone]': {
          type: :string,
          required: :required,
          description: 'Shops Phone'
        },
        'shop[hours_of_operation]' => {
          type: :string,
          required: :required,
          description: 'Hours of Operation'
        },
        'shop[techs_per_shift]' => {
          type: :string,
          required: :required,
          description: 'Amount of techs per shift'
        },
        'shop[certified]' => {
          type: :boolean,
          required: :required,
          description: 'Certified Techs or NotCertified (Mechanic shops only)'
        },
        'shop[lounge_area]' => {
          type: :boolean,
          required: :required,
          description: 'Lounge Area with amenities / No lounge area'
        },
        'shop[supervisor_permanently]' => {
          type: :boolean,
          required: :required,
          description: 'Supervisor on sight at all time / Seldom'
        },
        'shop[tow_track]' => {
          type: :boolean,
          required: :optional,
          description: 'Does your shop have a towtruck on sight? (mechanic shops only)'
        },
        'shop[complimentary_inspection]' => {
          type: :boolean,
          required: :required,
          description: 'Do you offer complimentary inspection?'
        },
        'shop[vehicle_warranties]' => {
          type: :boolean,
          required: :required,
          description: 'Work with vehicle warranties'
        },
        'shop[category]' => {
          type: :integer,
          required: :required,
          description: 'Category'
        },
        'shop[languages]' => {
          type: :array,
          required: :optional,
          description: 'Languages'
        },
        'shop[vehicle_diesel]' => {
          type: :boolean,
          required: :optional,
          description: 'Do you Work on Diesel vehicles (Mechanicshops only) ?'
        },
        'shop[vehicle_electric]' => {
          type: :boolean,
          required: :optional,
          description: 'Do you Work on Electric vehicles (Mechanicshops only) ?'
        },
        'shop[pictures_attributes]' => {
          type: :array,
          required: :required,
          description: 'At least 3 pics of the facility'
        },
        'shop[avatar]' => {
          type: :file,
          required: :optional,
          description: 'Shop avatar/logo'
        },
        'shop[additional_info]' => {
          type: :string,
          required: :optional,
          description: 'Additional Info'
        }
      }

      # Action Data
      document :create do
        action 'Create an account' do
          params create_params
        end
      end

      document :update do
        action 'Update an account'
      end
    end
  end
end
