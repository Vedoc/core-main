class AddDeviseConfirmableToAccounts < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:accounts, :confirmation_token)
      add_column :accounts, :confirmation_token, :string
      add_index :accounts, :confirmation_token, unique: true
    end

    unless column_exists?(:accounts, :confirmed_at)
      add_column :accounts, :confirmed_at, :datetime
    end

    unless column_exists?(:accounts, :confirmation_sent_at)
      add_column :accounts, :confirmation_sent_at, :datetime
    end

    unless column_exists?(:accounts, :unconfirmed_email)
      add_column :accounts, :unconfirmed_email, :string
    end
  end
end
