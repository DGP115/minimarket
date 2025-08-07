class AddDepthCacheToProductcategories < ActiveRecord::Migration[8.0]
  def change
    add_column :product_categories, :ancestry_depth, :integer, default: 0
    add_column :product_categories, :children_count, :integer, default: 0, null: false
  end
end
