require 'csv'
require 'json'

namespace :db do
  namespace :seed do
    desc "Import accounts from CSV"
    task accounts: :environment do
      file_path = Rails.root.join('db/seeds/accounts.csv')
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit
      end

      CSV.foreach(file_path, headers: true).with_index(1) do |row, index|
        begin
          # Parse tokens
          tokens = begin
            JSON.parse(row['Tokens'] || '{}')
          rescue JSON::ParserError
            {}
          end

          # Find or create accountable record
          accountable_type = row['Accountable type']
          accountable = if accountable_type == 'Shop'
            shop_name = row['Email'].split('@').first
            Shop.find_by(name: shop_name) || 
              Shop.create!(
                name: shop_name,
                owner_name: 'Default Owner',
                hours_of_operation: '9:00 AM - 5:00 PM',
                categories: [1],
                phone: '+1 (000) 000-0000',
                location: 'POINT(-95.3698 29.7604)',
                techs_per_shift: 1,
                address: 'Default Address',
                pictures: ['default.jpg'],
                approved: true
              )
          end

          account = Account.find_or_create_by!(
            id: row['Id'],
            provider: row['Provider'],
            uid: row['Uid'],
            encrypted_password: row['Encrypted password'],
            email: row['Email'],
            employee: row['Employee'] == 'true',
            accountable: accountable,
            tokens: tokens,
            created_at: row['Created at'],
            updated_at: row['Updated at']
          )

          puts "Imported account #{account.email} (ID: #{account.id})"

        rescue ActiveRecord::RecordInvalid => e
          puts "Failed to import row #{index}: #{row.to_h}. Error: #{e.message}"
        end
      end

      puts "Account import completed successfully."
    end
  end
end 