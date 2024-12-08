class AddApprovedToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :approved, :boolean, default: true, null: false
  end
end
