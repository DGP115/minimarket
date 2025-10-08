class AddNotificationModel < ActiveRecord::Migration[8.0]
  def change
    create_table :review_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :review, null: false, foreign_key: true
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
