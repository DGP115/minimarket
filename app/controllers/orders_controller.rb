class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: %i[ show destroy ]

  # GET /orders or /orders.json
  def index
    # Take advantage of sortable view columns provided by ransack gem
    @query = current_user.orders
                         .ransack(params[:q])

    @orders = @query.result(distinct: true)

    # Apply default ordering only when no sort param is present
    unless params.dig(:q, :s).present?
      @orders = @orders.order(created_at: :desc)
    end

    # Recall:  .size is more efficient than .count here because @orders is already loaded.
    #          .size just returns the length of the in-memory array, whereas .count would issue a new SQL COUNT query.
    @num_orders = @orders.size

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /orders/1 or /orders/1.json
  def show
    @order_lineitems = @order.lineitems.order(created_at: :asc).includes(:product)
  end



  # DELETE /orders/1 or /orders/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to orders_path, status: :see_other, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.expect(order: [ :user_id, :status, :total_amount ])
    end
end
