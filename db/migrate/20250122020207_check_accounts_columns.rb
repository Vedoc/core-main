class CheckAccountsColumns < ActiveRecord::Migration[7.1]
  def up
    columns = ActiveRecord::Base.connection.columns('accounts')
    puts "\nCurrent columns in accounts table:"
    columns.each do |col|
      puts "- #{col.name} (#{col.type})"
    end
  end

  def down
    # No need for down migration yet!
  end
end
