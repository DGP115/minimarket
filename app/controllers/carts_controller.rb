class CartsController < ApplicationController
  # authenticate_user! is provided by Devise
  before_action :authenticate_user!

  before_action :set_cart, only: %i[ show edit update destroy checkout]
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

  def checkout
    # Create an order.  Status is pending until payment is received
    create_order_from_cart

    # Create Stripe checkout session
    # NOTE:  Upon completion of the Stripe checkout session, Stripe will call our webhook
    #        (see webhooks_controller.rb) to notify us that the payment was successful.
    #        At that point, we will update the order status to accepted.
    #        Also, at the point of successful payment, the "success_url" (below) will be invoked
    #        to redirect the user to the order's Show page.
    session = Stripe::Checkout::Session.create({
      client_reference_id: @order.id,
      line_items: @order.lineitems.map { |lineitem|
          {
            price: Stripe::Product.retrieve(lineitem.product.stripe_id).default_price,
            quantity: lineitem.quantity.to_i
          }
        },
      customer_email: current_user&.email,
      mode: "payment",
      success_url: order_url(@order),
      cancel_url: cart_url
    })
    redirect_to session.url, status: 303, allow_other_host: true and return
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

  def create_order_from_cart
    @order = current_user.orders.build(status: :pending, status_changed_at: Time.current, total_amount: @cart.total_purchase)

    # Move cart items to order items
    @cart.cart_items.each do |cart_item|
      @order.lineitems.build(
        product_id: cart_item.product_id,
        quantity: cart_item.quantity,
        unit_price: cart_item.product.price,
        buyer_id: current_user.id
      )
    end

    # Use a transaction to ensure that either both the order is saved and cart destroyed,
    # or neither happens (in case of error)
    ActiveRecord::Base.transaction do
      @order.save!
      @cart.destroy!
      # Create a new empty cart for the user
      current_user.create_cart!
    end

  rescue ActiveRecord::RecordInvalid
    # If something goes wrong, render the cart page again with error message.
    # In this case, the cart and order will be unchanged.
    set_cart
    set_sorted_cart_items
    flash.now[:alert] = "There was a problem creating your order. Please try again."
    render :show, status: :unprocessable_entity
  end
end
