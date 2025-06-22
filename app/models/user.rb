class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # i.e. A user, as a seller, has many products.
  # When a user-as-seller is deleted, so are their products
  has_many :products, foreign_key: :seller_id, dependent: :destroy

  # i.e. A user, as a buyer, has many purchases.
  # When a user-as-buyer is deleted, so are their purchases
  has_many :purchases, foreign_key: :buyer_id, dependent: :destroy

  def has_purchased?(product)
    # Check if the user has purchased the product
    purchases.exists?(product_id: product.id)
  end
end
