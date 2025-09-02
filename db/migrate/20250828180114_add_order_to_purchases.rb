class AddOrderToPurchases < ActiveRecord::Migration[8.0]
  def change
    add_reference :purchases, :order, foreign_key: true
  end
end
