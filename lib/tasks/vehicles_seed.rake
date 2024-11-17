require 'csv'

namespace :db do
  namespace :seed do
    desc "Seed vehicles from a CSV file"
    task vehicles: :environment do
      # Define the path to the CSV file
      file_path = Rails.root.join('db/seeds/vehicles.csv')
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit
      end

      # Ensure CarCategory exists
      %w[car truck].each do |category|
        CarCategory.find_or_create_by!(name: category)
      end

      # Read and process the CSV file
      CSV.foreach(file_path, headers: true).with_index(1) do |row, index|
        begin
          # Ensure correct capitalization for CSV headers
          make_name = row['Make'] || row['make']
          model_name = row['Model'] || row['model']
          year = row['Year'] || row['year']
          category = row['Category'] || row['category']

          # Skip rows with missing data
          if make_name.blank? || model_name.blank? || year.blank? || category.blank?
            puts "Skipped row #{index} with missing data: #{row.to_h}"
            next
          end

          # Find or create associated records
          car_category = CarCategory.find_by(name: category) || CarCategory.first
          make = CarMake.find_or_create_by!(name: make_name, car_category: car_category)
          model = CarModel.find_or_create_by!(name: model_name, car_make: make)
          ModelYear.find_or_create_by!(year: year, car_model: model)

          # Create the actual Vehicle record
          Vehicle.create!(
            make: make_name,
            model: model_name,
            year: year,
            category: category,
            client_id: nil # Skipping client association for seeding
          )

          puts "Imported vehicle #{make_name} #{model_name} (#{year})"

        rescue ActiveRecord::RecordInvalid => e
          puts "Failed to import row #{index}: #{row.to_h}. Error: #{e.message}"
        end
      end

      puts "Vehicle import completed successfully."
    end
  end
end
