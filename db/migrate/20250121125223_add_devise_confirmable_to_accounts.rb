class AddDeviseConfirmableToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :confirmation_token, :string
    add_column :accounts, :confirmation_sent_at, :datetime
    add_column :accounts, :unconfirmed_email, :string

    add_index :accounts, :confirmation_token, unique: true
  end
end
