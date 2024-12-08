class AddLockableToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :failed_attempts, :integer
    add_column :accounts, :unlock_token, :string
    add_column :accounts, :locked_at, :datetime
  end
end
