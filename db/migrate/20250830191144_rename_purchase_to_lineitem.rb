class RenamePurchaseToLineitem < ActiveRecord::Migration[8.0]
  def change
    rename_table :purchases, :lineitems
  end
end
