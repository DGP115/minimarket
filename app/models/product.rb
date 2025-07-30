class Product < ApplicationRecord
  # Because sellers and buyers are both users, we are telling rails the class
  # the product model is associated with [normally, it would be inferred in the 'belongs_to']
  belongs_to :seller, class_name: "User"

  has_many :purchases, dependent: :destroy
  has_many :buyers, through: :purchases, class_name: "User"
  has_many :reviews, dependent: :destroy

  has_one_attached :primary_image, dependent: :destroy
  has_many_attached :images, dependent: :destroy

  has_rich_text :description

  # Syncronize stripe product model with changes made to this product model
  after_create :create_product_in_stripe
  after_update :update_product_in_stripe
  after_destroy :archive_product_in_stripe

  private

  def create_product_in_stripe
    begin
      # Create a product in Stripe to "match" the app product
      stripe_product = Stripe::Product.create({
        name: self.title,
        type: "good",
        active: true
      })

      # Create a Stripe price object for the product (in Stripe)
      stripe_price = Stripe::Price.create({
        unit_amount: (self.price * 100).to_i, # Convert to cents
        currency: "cad",
        billing_scheme: "per_unit",
        product: stripe_product.id
      })

      # Set the default_price of the new Stripe product to the new Stripe price
      Stripe::Product.update(stripe_product.id, { default_price: stripe_price.id })

      # Update the app product object with its Stripe product ID
      self.stripe_id = stripe_product.id

      self.save

    rescue Stripe::StripeError => e
      flash[:alert] = "Error updating product #{self.title}: #{e.message}"
    end
  end

  def update_product_in_stripe
    begin
      if self.stripe_id.present?
        stripe_product = Stripe::Product.retrieve(self.stripe_id)
        # So far the only app-product attributes synced with stripe are title and price.
        # 1.  Update title
        Stripe::Product.update(stripe_product.id, { name: self.title })

        # The updating of prices in stripe is more involved, so only bother if the price has changed.
        # 2. Get the default_price object from the stripe product object
        current_default_price = Stripe::Price.retrieve(stripe_product.default_price)
        current_unit_amount_cents = current_default_price.unit_amount

        if self.price * 100.to_f != current_unit_amount_cents.to_f

          # Price has changed so:
          # 3.1  Disassociate the old default_price object from the stripe product
          Stripe::Product.update(stripe_product.id, { default_price: "" })

          # 3.2  Deactivate the old stripe price object
          Stripe::Price.update(current_default_price.id, { active: false })

          # 3.3. Create a new price object
          stripe_price = Stripe::Price.create({
            unit_amount: (self.price * 100).to_i, # Convert to cents
            currency: "cad",
            billing_scheme: "per_unit",
            product: stripe_product.id
          })

          # 3.4  Set the default_price of the Stripe product to the new Stripe price
          Stripe::Product.update(stripe_product.id, { default_price: stripe_price.id })

          true  # return true
        end
      else
        false
        Rails.logger.warn "Product #{self.title} has no Stripe ID, skipping price update."
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to update Stripe for product: #{self.title}: #{e.message}"
    end
  end

  # Stripe suggests archiving products instead of deleting them.
  def archive_product_in_stripe
    begin
      if self.stripe_id.present?
        # 1. Disassocate the stripe product obhect and its price object.
        #    Set the default price of the stripe product to null
        Stripe::Product.update(self.stripe_id, { default_price: "" })

        # 2. List all prices for this product
        prices = Stripe::Price.list(product: self.stripe_id)

        # 3. Deactivate each associated price
        prices.each do |price|
          Stripe::Price.update(price.id, { active: false })
        end

        # 4. Deactivate the stripe product itself
        Stripe::Product.update(self.stripe_id, { active: false })
        true  # return true
      else
        false
        Rails.logger.warn "Product #{self.id} has no Stripe ID, skipping archiving."
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to archive product #{self.title} in Stripe: #{e.message}"
    end
  end
end
