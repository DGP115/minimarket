class Order < ApplicationRecord
  belongs_to :user

  has_many :lineitems
  has_many :products, through: :lineitems

  enum :status, { pending: 0,
                  processing: 10,
                  fulfilled: 20,
                  cancelled: 30,
                  refunded: 40 },
                  default: :pending
end
