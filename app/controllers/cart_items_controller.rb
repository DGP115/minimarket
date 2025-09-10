class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[ destroy ]
  # Only logged-in users can add items to a cart
  before_action :authenticate_user!

  # POST /cart_items
  def create
    @cart = Cart.find_or_create_by(user_id: current_user.id)
    @product = Product.find(params[:product_id])
    if !@cart.products.exists?(id: @product.id) && params[:quantity].to_i > 0
      @cart.cart_items.create!(product: @product, quantity: params[:quantity])
      flash[:notice] = "Item added to cart"
      redirect_to cart_path(@cart)
    else
      redirect_to product_path(@product)
      flash[:alert] = "Item is already on your cart."
    end
  end

  # DELETE /cart_items/1
  def destroy
    if @cart_item.destroy
      head :no_content  # Sends HTTP 204, no redirect or view since handled by js controller
    else
      redirect_to cart_path, alert: "Item could not be removed from cart"
    end
  end

  private

    def set_cart_item
      @cart_item = CartItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cart_item_params
      params.expect(cart_item: [ :cart_id, :product_id, :quantity ])
    end
end
