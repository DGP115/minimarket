class Purchase < ApplicationRecord
  belongs_to :product
  # Because sellers and buyers are both users, we are telling rails the class
  # the Purchase model is associated with [normally, it would be inferred in the 'belongs_to']
  belongs_to :buyer, class_name: "User"
end
