class UpdateExistingClientsApproved < ActiveRecord::Migration[7.1]
  def change
    Client.update_all(approved: true)
  end
end
