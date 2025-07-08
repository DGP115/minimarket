class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy buy ]
  # authenticate_user is provided by Devise
  before_action :authenticate_user!, only: %i[ new create edit update destroy buy]
  before_action :require_same_user, only: %i[ edit update destroy ]

  # See https://guides.rubyonrails.org/action_controller_advanced_topics.html#authenticity-token-and-request-forgery-protection
  protect_from_forgery except: :webhook

  def index
    @products = Product.all
  end

  def show
    # Will need product reviews
    @reviews = @product.reviews.order(created_at: :desc)
    # Be ready with a new review object
    @new_review = @product.reviews.new(user_id: current_user&.id)
  end

  def new
    @product = current_user.products.new
  end

  def create
    @product = current_user.products.new(whitelisted_params)
    create_product_in_stripe

    if @product.save
      flash[:notice] = "Product #{@product.title} successfully created"
      redirect_to product_path(@product)
    else
      # Error trapping
      #   Re-render the "new" product page.
      #   Because the save returned false, the error trapping on the "new" page
      #   will display the errors
      render "new", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if product_price_changed?
      # Update stripe price object(s)
      if !update_stripe_price
        render "edit", status: :unprocessable_entity and return
      end
    end
    if @product.update(whitelisted_params)
      flash[:notice] = "Product #{@product.title} updated successfully"
      redirect_to product_path(@product)
    else
      # Error trapping
      #   Re-render the "edit" product page.
      #   Because the save returned false, the error trapping on the "new" page
      #   will display the errors
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    # Archive the Stripe variant of this product (product and price objects)
    stripe_archive_status = archive_stripe_product

    if @product.destroy && stripe_archive_status

      flash[:notice] = "Product #{@product.title} deleted"
      redirect_to products_path

    else
      # Error trapping
      #   Re-render the "edit" product page.
      #   Because the save returned false, the error trapping on the "edit" page
      #   will display the errors
      render "edit", status: :unprocessable_entity
    end
  end

  def buy
    quantity = params[:product][:quantity].to_i
    if quantity > 0
      stripe_product = Stripe::Product.retrieve(@product.stripe_id)
      stripe_price = stripe_product.default_price
      session = Stripe::Checkout::Session.create({
        client_reference_id: @product.id,
        line_items: [ {
          price: stripe_price,
          quantity: quantity
        } ],
        customer_email: current_user&.email,
        mode: "payment",
        success_url: product_url(@product),
        cancel_url: product_url(@product)
      })
      redirect_to session.url, status: 303, allow_other_host: true
    else
      # If quantity is greater than 0, redirect to the product page with an error message
      flash[:alert] = "Quantity must be greater than 0"
      redirect_to product_path(@product), status: :unprocessable_entity
    end
  end

  def webhook
    # This method is called by Stripe when an event occurs.
    # In development, a seaprate lsitengin process must be run to listen for webhooks
    # e.g.  $ stripe listen --forward-to localhost:3000/webhook
    # It verifies the event (to ensure it comes from Stripe) and then processes it accordingly.
    # The event is nil if verification fails.
    # Note:  "payload" is the full record of data provided by Stripe regarding the transaction

    event = nil
    begin
      payload = request.body.read
      signature_header = request.env["HTTP_STRIPE_SIGNATURE"]
      event = Stripe::Webhook.construct_event(
              payload,
              signature_header,
              Rails.application.credentials.dig(:stripe, :webhook_endpoint_secret))
    rescue JSON::ParserError => e
      # Invalid payload
      render json: { status: 400, error: e.message } and return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: { status: 400, error: e.message } and return
    end

    if event["type"] == "checkout.session.completed"
        # The checkout session was completed successfully.
        customer_email = event.data.object.customer_email
        product_id = event.data.object.client_reference_id # Because we set it to that in the buy method
        customer = User.find_by(email: customer_email)
        purchase = customer.purchases.create(product_id: product_id)
    end

    # Return a 200 OK response to acknowledge with Stripe receipt of the event
    render json: { status: 200, message: "Webhook received" }
  end

  def remove_image
    @product = Product.find(params[:product_id])

    begin
      image_to_remove = ActiveStorage::Attachment.find(params[:id])
      image_to_remove.purge
        flash[:notice] = "Image removed successfully"
        redirect_to edit_product_path(@product)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = "Invalid image ID"
      redirect_to edit_product_path(@product), status: :unprocessable_entity and return
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Image not found"
      redirect_to edit_product_path(@product), status: :not_found and return
    rescue => e
      Rails.logger.error "Failed to remove image: #{e.message}"
      flash[:alert] = "Failed to remove image"
      redirect_to edit_product_path(@product), status: :internal_server_error and return
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def whitelisted_params
    params.expect(product: [ :title, :description, :price, :primary_image, images: [] ])
  end

  def require_same_user
    if @product.seller_id != current_user.id
      flash[:alert] = "You can only alter your own products"
      redirect_to @product
    end
  end

  def create_product_in_stripe
    begin
      # Create a product in Stripe to "match" the app product
      stripe_product = Stripe::Product.create({
        name: @product.title,
        type: "good",
        active: true
      })

      # Create a Stripe price object for the product (in Stripe)
      stripe_price = Stripe::Price.create({
        unit_amount: (@product.price * 100).to_i, # Convert to cents
        currency: "cad",
        billing_scheme: "per_unit",
        product: stripe_product.id
      })

      # Set the default_price of the new Stripe product to the new Stripe price
      Stripe::Product.update(stripe_product.id, { default_price: stripe_price.id })

      # Update the app product object with its Stripe product ID
      @product.stripe_id = stripe_product.id

    rescue Stripe::StripeError => e
      flash[:alert] = "Error updating product: #{e.message}"
    end
  end

  def archive_stripe_product
    begin
      if @product.stripe_id.present?
        # 1. Set the default price of the stripe product to null
        Stripe::Product.update(@product.stripe_id, { default_price: "" })

        # 2. List all prices for this product
        prices = Stripe::Price.list(product: @product.stripe_id)

        # 3. Deactivate each assocated price
        prices.each do |price|
          Stripe::Price.update(price.id, { active: false })
        end

        # 4. Deactivate the stripe product itself
        Stripe::Product.update(@product.stripe_id, { active: false })
        true  # return true
      else
        false
        Rails.logger.warn "Product #{@product.id} has no Stripe ID, skipping archiving."
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to archive product in Stripe: #{e.message}"
    end
  end

  def product_price_changed?
    params[:product][:price].to_f != @product.price.to_f
  end

  def update_stripe_price
    begin
      if @product.stripe_id.present?
        # 1.  Get the default_price of the stripe product object
        stripe_product = Stripe::Product.retrieve(@product.stripe_id)
        default_price_id = stripe_product.default_price

        # 2.  Disassociate the old default_price object from the product
        Stripe::Product.update(stripe_product.id, { default_price: "" })

        # 3. Deactivate the old price object
        Stripe::Price.update(default_price_id, { active: false })

        # 4. Create a new price object
        stripe_price = Stripe::Price.create({
          unit_amount: (params[:product][:price].to_i * 100), # Convert to cents
          currency: "cad",
          billing_scheme: "per_unit",
          product: stripe_product.id
        })

        # 5 Set the default_price of the Stripe product to the new Stripe price
        Stripe::Product.update(stripe_product.id, { default_price: stripe_price.id })

        true  # return true
      else
        false
        Rails.logger.warn "Product #{@product.id} has no Stripe ID, skipping price update."
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to change price in Stripe: #{e.message}"
    end
  end
end
