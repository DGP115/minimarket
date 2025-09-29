class WebhooksController < ApplicationController
  # See https://guides.rubyonrails.org/action_controller_advanced_topics.html#authenticity-token-and-request-forgery-protection
  protect_from_forgery except: :set_stripe_webhook

  def set_stripe_webhook
    # This method is called by Stripe when an event occurs.
    # In this case, we are checking for "checkout.session.completed" events, which means the user payment using Stripe was successful
    #
    # In development, a separate listening process must be run to listen for webhooks
    # e.g.  $ stripe listen --forward-to localhost:3000/webhook
    #
    # Specifically, this method verifies the event (to ensure it comes from Stripe) and then processes it accordingly.
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
        # The checkout session was completed successfully, meaning payment was successfuly received by Stripe.
        customer_email = event.data.object.customer_email
        order_id = event.data.object.client_reference_id # Because we set it to that in the buy method
        order = Order.find_by(id: order_id, status: :pending)
        customer = order&.user

        if order
          order.update!(status: :accepted, status_changed_at: Time.current)
        end
    end

    # Return a 200 OK response to acknowledge with Stripe receipt of the event
    render json: { status: 200, message: "Webhook received" }
  end
end
