class Product < ApplicationRecord
  # Because sellers and buyers are both users, we are telling rails the class
  # the product model is associated with [normally, it would be inferred in the 'belongs_to']
  belongs_to :seller, class_name: "User"

  has_many :purchases, dependent: :destroy
  has_many :buyers, through: :purchases, class_name: "User"

  has_one_attached :primary_image, dependent: :destroy
  has_many_attached :images, dependent: :destroy
end
