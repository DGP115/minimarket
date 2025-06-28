class AddPurchaseQuantity < ActiveRecord::Migration[8.0]
  def change
    add_column :purchases, :quantity, :integer, default: 1, null: false
  end
end
