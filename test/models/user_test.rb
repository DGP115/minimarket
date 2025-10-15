require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_one)
    @product = products(:product_one)
    @cart = carts(:cart_one)
    @order = orders(:order_one)
  end

  test "Has purchased product" do
    assert @user.has_purchased?(@product)
  end
end
