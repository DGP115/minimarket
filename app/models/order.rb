class Order < ApplicationRecord
  belongs_to :user

  has_many :lineitems, dependent: :destroy
  has_many :products, through: :lineitems

  enum :status, { pending: 0,
                  processing: 10,
                  fulfilled: 20,
                  cancelled: 30,
                  refunded: 40 },
                  default: :pending

  # Ransack needs Order attributes explicitly allowlisted as searchable
  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "id", "status", "status_changed_at", "total_amount", "updated_at" ]
  end
end
