class AddProductscountToProductCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :product_categories, :products_count, :integer, default: 0, null: false
  end
end
