class LineitemsUnitPriceToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :lineitems, :unit_price, :decimal, precision: 6, scale: 2, default: "0.0", null: false
  end
end
