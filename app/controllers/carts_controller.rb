class CartsController < ApplicationController
  before_action :set_cart, only: %i[ show edit update]
  # authenticate_user! is provided by Devise
  before_action :authenticate_user!

  # GET /carts/1 or /carts/1.json
  def show
  end

  def edit
    @cart = current_user.cart
  end

  def update
    if @cart.update(cart_params)
      @cart.cart_items.where(quantity: 0).destroy_all
      redirect_to @cart
      flash[:notice] = "Your cart was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cart
    @cart = current_user.cart
  end

  def cart_params
    # See cart model.  We have allowed cart model with edit of cart_items.
    # That is why we can use cart_items_attributes here.
    params.require(:cart).permit(cart_items_attributes: [ :id, :quantity, :_destroy ])
  end
end
