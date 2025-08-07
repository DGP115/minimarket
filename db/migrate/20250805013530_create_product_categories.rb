class CreateProductCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :product_categories do |t|
      t.string :name
      t.string :description
      t.string "ancestry", collation: 'C', null: false
      t.index "ancestry"

      t.timestamps
    end
  end
end
