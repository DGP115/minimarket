class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy buy ]

  # authenticate_user! is provided by Devise
  before_action :authenticate_user!, only: %i[ new create edit update destroy buy]

  before_action :require_same_user, only: %i[ edit update destroy ]

  # See https://guides.rubyonrails.org/action_controller_advanced_topics.html#authenticity-token-and-request-forgery-protection
  protect_from_forgery except: :webhook

  def show
    # Will need product reviews
    @reviews = @product.reviews.order(created_at: :desc).includes([ :user ])
    # Be ready with a new review object
    @new_review = @product.reviews.new(user_id: current_user&.id)
  end

  def new
    @product = current_user.products.new
    if !params[:product_category_id].nil?
      @product.product_category_id = params[:product_category_id]
      set_product_category_tree
    else
      flash[:alert] = "Can't create a product without specifying a category"
      render "new", status: :unprocessable_entity
    end
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
    set_product_category_tree
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
      # If quantity is not greater than 0, redirect to the product page with an error message
      flash[:alert] = "Quantity must be greater than 0"
      redirect_to product_path(@product), status: :unprocessable_entity
    end
  end

  def webhook
    # This method is called by Stripe when an event occurs.
    # In development, a separate listening process must be run to listen for webhooks
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
        lineitem = customer.lineitems.create(product_id: product_id)
    end

    # Return a 200 OK response to acknowledge with Stripe receipt of the event
    render json: { status: 200, message: "Webhook received" }
  end

  def remove_image
    @product = Product.find(params[:id])

    begin
      # image_to_remove = ActiveStorage::Attachment.find(params[:id])
      image_to_remove = @product.images.find(params[:attachment_id])
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
    # @product = Product.includes(product_category: {}).with_attached_images.limit(10).find(params[:id])
    @product = Product.find(params[:id])
  end

  def set_product_category_tree
    root = @product.product_category.root
    #  Need ALL product categories [under this root] to populate the dropdown that allows the user
    #  to reassign the product's category
    @product_categories = root.descendants.arrange(order: :name)
  end

  def whitelisted_params
    params.expect(product: [ :title, :description, :price, :product_category_id, :primary_image, images: [] ])
  end

  def require_same_user
    if @product.seller_id != current_user.id
      flash[:alert] = "You can only alter your own products"
      redirect_to @product
    end
  end
end
