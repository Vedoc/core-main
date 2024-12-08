class ChangeDefaultForApprovedInShops < ActiveRecord::Migration[7.1]
  def change
    change_column_default :shops, :approved, from: false, to: true
  end
end
