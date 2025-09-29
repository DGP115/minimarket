class AddPurchaseAmountToLineitems < ActiveRecord::Migration[8.0]
  def change
    add_column :lineitems, :purchase_amount, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
