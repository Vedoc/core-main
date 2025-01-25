class RemoveStringFromVehicles < ActiveRecord::Migration[7.1]
  def change
    remove_column :vehicles, :string, :string
  end
end
