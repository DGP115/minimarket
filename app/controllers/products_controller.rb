class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy buy ]
  # authenticate_user is provided by Devise
  before_action :authenticate_user!, only: %i[ new create edit update destroy buy]
  before_action :require_same_user, only: %i[ edit update destroy ]

  protect_from_forgery except: :webhook

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = current_user.products.new
  end

  def create
    @product = current_user.products.new(whitelisted_params)
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
    if @product.destroy
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
    session = Stripe::Checkout::Session.create({
      client_reference_id: @product.id,
      line_items: [ {
        price: "price_1Rc7NeQtzLVdfZ1smDaUW7tj",
        quantity: 1
      } ],
      customer_email: current_user&.email,
      mode: "payment",
      success_url: product_url(@product),
      cancel_url: product_url(@product)
    })
    redirect_to session.url, status: 303, allow_other_host: true
  end

  def webhook
    # This method is called by Stripe when a webhook event occurs.
    # It verifies the event (to ensure it ocmes from Stripe) and then processes it accordingly.
    # The event is nil if verification fails.
    # Note:  "payload" is the full record of data provided by Stripe regarding the transcation

    event = nil
    begin
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      event = Stripe::Webhook.construct_event(
              payload,
              sig_header,
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
    params.expect(product: [ :title, :description, :price, images: [] ])
  end

  def require_same_user
    if @product.seller_id != current_user.id
      flash[:alert] = "You can only alter your own products"
      redirect_to @product
    end
  end
end
