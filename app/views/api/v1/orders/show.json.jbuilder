json.status "success"
json.message "Order loaded successfully"

json.order  do
  json.id @order.id
  json.user_id @order.user_id
  json.total_amount @order.total_amount
  json.status @order.status
  json.created_at @order.created_at
  json.updated_at @order.updated_at
end



