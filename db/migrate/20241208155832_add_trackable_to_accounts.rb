class AddTrackableToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :sign_in_count, :integer
    add_column :accounts, :current_sign_in_at, :datetime
    add_column :accounts, :last_sign_in_at, :datetime
    add_column :accounts, :current_sign_in_ip, :string
    add_column :accounts, :last_sign_in_ip, :string
  end
end
