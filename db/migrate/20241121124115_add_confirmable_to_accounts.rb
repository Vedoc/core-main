class AddConfirmableToAccounts < ActiveRecord::Migration[7.1]
  def up
    add_column :accounts, :confirmation_token, :string
    add_column :accounts, :confirmed_at, :datetime
    add_column :accounts, :confirmation_sent_at, :datetime
    # add_column :accounts, :unconfirmed_email, :string # Only needed if using reconfirmable
    add_index :accounts, :confirmation_token, unique: true

    # Optional: Set default confirmed_at for existing records to mark them as confirmed
    Account.update_all(confirmed_at: Time.current)
  end

  def down
    remove_index :accounts, :confirmation_token
    remove_column :accounts, :confirmation_token
    remove_column :accounts, :confirmed_at
    remove_column :accounts, :confirmation_sent_at
    remove_column :accounts, :unconfirmed_email
  end
end
