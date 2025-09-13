class CartsController < ApplicationController
  before_action :set_cart, only: %i[ show edit update destroy ]
  # authenticate_user! is provided by Devise
  before_action :authenticate_user!

  # GET /carts/1
  def show
    # Ensure this is initalized so second row of navbar works
    @root_categories = ProductCategory.roots.order(orderindex: :asc)
  end

  def edit
    @cart = current_user.cart
  end

  def update
    if @cart.update(cart_params)
      # Delete items user has supplied a zero quantity for.
      @cart.cart_items.where(quantity: 0).destroy_all

      # Reload from DB to get true persisted state
      @cart.reload

      # Broadcast navbar update with DB values
      # Turbo::StreamsChannel.broadcast_replace_to(
      #   "cart_button",
      #   partial: "layouts/navbar/cart_icon",
      #   locals: {
      #     cart: @cart,
      #     total_quantity: @cart.total_quantity,
      #     total_purchase: @cart.total_purchase
      #   }
      # )

      redirect_to @cart
      flash[:notice] = "Your cart was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @cart.destroy
      flash[:notice] = "Your cart was successfully deleted"
      redirect_to root_path
    else
      render "show", status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = current_user.cart
  end

  def cart_params
    # See cart model.  We have allowed cart model with edit of cart_items.
    # That is why we can use cart_items_attributes here.
    params.require(:cart).permit(cart_items_attributes: [ :id, :quantity, :_destroy ])
  end
end
