class CartsController < ApplicationController
  before_action :set_cart, only: %i[ show edit ]
  # authenticate_user! is provided by Devise
  before_action :authenticate_user!

  # GET /carts/1 or /carts/1.json
  def show
  end

  def edit
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = current_user.cart
    end
end
