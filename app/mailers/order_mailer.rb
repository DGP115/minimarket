class OrderMailer < ApplicationMailer
  def order_confirmation
    # See webhooks_controller.  Called with order_id as params when the Stripe webhook confirms payment was successful
    @order = Order.find(params[:order_id])
    @customer = @order.user

    mail(
      to: @customer.email,
      subject: "Order Confirmation - ##{@order.id}"
    )
  end
end
