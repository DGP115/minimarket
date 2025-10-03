class OrderMailer < ApplicationMailer
  def order_confirmation
    @order = Order.find(params[:order_id])
    @customer = @order.user

    mail(
      to: @customer.email,
      subject: "Order Confirmation - ##{@order.id}"
    )
  end
end
