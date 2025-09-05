class CartsController < ApplicationController
  before_action :set_cart, only: %i[ show edit update ]
  # authenticate_user! is provided by Devise
  before_action :authenticate_user!

  # GET /carts/1 or /carts/1.json
  def show
  end

  def edit
  end

  def update
    if @cart.update(cart_params)
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
      params.require(:cart).permit(cart_items_attributes: [ :id, :quantity ])
    end
end
