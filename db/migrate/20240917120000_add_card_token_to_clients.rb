class AddCardTokenToClients < ActiveRecord::Migration[7.1]
    def change
      add_column :clients, :card_token, :string
    end
  end
  