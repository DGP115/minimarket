json.extract! order, :id, :user_id, :status, :total_amount, :created_at, :updated_at
json.url order_url(order, format: :json)
