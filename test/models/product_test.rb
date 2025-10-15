require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @product = products(:product_one)
  end

  test "product title should be present" do
    @product.title = ""
    assert_not @product.valid?
    assert_includes @product.errors[:title], "can't be blank"
  end
  test "product price should be present" do
    @product.price = nil
    assert_not @product.valid?
    assert_includes @product.errors[:price], "can't be blank"
  end
  test "product price must be > 0" do
    @product.price = 0
    assert_not @product.valid?
    assert_includes @product.errors[:price], "must be greater than 0"
    @product.price = -1.0
    assert_not @product.valid?
    assert_includes @product.errors[:price], "must be greater than 0"
  end
end
