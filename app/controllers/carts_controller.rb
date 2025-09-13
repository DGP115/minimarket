class CartsController < ApplicationController
  # authenticate_user! is provided by Devise
  before_action :authenticate_user!

  before_action :set_cart, only: %i[ show edit update destroy ]
  before_action :set_sorted_cart_items, only: %i[ show edit ]

  # GET /carts/1
  def show
  end

  def edit
  end

  def update
    if @cart.update(cart_params)
      # Delete items user has supplied a zero quantity for.
      @cart.cart_items.where(quantity: 0).destroy_all

      # Reload from DB to get true persisted state
      @cart.reload

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

  def set_sorted_cart_items
    # Show cart items in the order in which they were created
    @cart_items = @cart.cart_items.order(created_at: :asc)
  end

  def cart_params
    # See cart model.  We have allowed cart model with edit of cart_items.
    # That is why we can use cart_items_attributes here.
    params.require(:cart).permit(cart_items_attributes: [ :id, :quantity, :_destroy ])
  end
end
