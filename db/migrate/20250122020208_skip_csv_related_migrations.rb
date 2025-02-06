class SkipCsvRelatedMigrations < ActiveRecord::Migration[7.1]
  def up
    migrations_to_skip = [
      '20240125133331', # remove_string_from_vehicles
      '20240125133332', # other problematic migrations
    ]

    migrations_to_skip.each do |version|
      unless migration_exists?(version)
        execute "INSERT INTO schema_migrations (version) VALUES ('#{version}')"
        puts "Skipped migration version: #{version}"
      else
        puts "Migration version already skipped: #{version}"
      end
    end
  end

  def down
    migrations_to_skip = [
      '20240125133331',
      '20240125133332',
    ]

    migrations_to_skip.each do |version|
      execute "DELETE FROM schema_migrations WHERE version = '#{version}'"
      puts "Reverted skipped migration version: #{version}"
    end
  end

  private

  def migration_exists?(version)
    result = ActiveRecord::Base.connection.select_value(
      "SELECT 1 FROM schema_migrations WHERE version = '#{version}' LIMIT 1"
    )
    !result.nil?
  end
end
