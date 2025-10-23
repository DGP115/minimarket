class CartItemsController < ApplicationController
  # Only logged-in users can add items to a cart
  before_action :authenticate_user!

  # POST /cart_items
  def create
    @cart = Cart.find_or_create_by(user_id: current_user.id)
    @product = Product.find(params[:cart_item][:product_id])

    if !@cart.products.exists?(id: @product.id) && params[:cart_item][:quantity].to_i > 0

      @cart.cart_items.create!(product: @product, quantity: params[:cart_item][:quantity])

      # Show cart items in the order in which they were created
      @cart_items = @cart.cart_items.order(created_at: :asc)

      respond_to do |format|
        format.turbo_stream
        format.html {
          flash[:notice] = "Item added to cart"
          redirect_to product_path(@product)
        }
      end

    else
      respond_to do |format|
        format.html {
          flash[:alert] = "Item is already on your cart."
          redirect_to product_path(@product)
        }
      end
    end
  end

  # Not needed since deltes handled with _delete flags and the cart controller
  # def destroy
  #   if @cart_item.destroy
  #     head :no_content  # Sends HTTP 204, no redirect or view
  #   else
  #     redirect_to cart_path, alert: "Item could not be removed from cart"
  #   end
  # end

  private

    def set_cart_item
      @cart_item = CartItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cart_item_params
      params.expect(cart_item: [ :cart_id, :product_id, :quantity ])
    end
end
