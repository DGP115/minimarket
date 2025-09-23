class AddUnitpriceToLineitems < ActiveRecord::Migration[8.0]
  def change
    add_column :lineitems, :unit_price, :integer, null: false, default: 0
    change_column_default :lineitems, :quantity, from: 1, to: 0
  end
end
