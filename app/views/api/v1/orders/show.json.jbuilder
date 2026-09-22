json.status "success"
json.message "Order loaded successfully"

json.order do
  json.id @order.id
  json.user_id @order.user_id
  json.total_amount @order.total_amount
  json.shipping_charge @order.shipping_charge
  json.discount @order.discount
  json.status @order.status
  json.placed_at @order.placed_at
  json.created_at @order.created_at
  json.updated_at @order.updated_at

  json.order_items @order.order_items do |order_item|
    json.id order_item.id
    json.quantity order_item.quantity
    json.unit_price order_item.unit_price
    json.total_price order_item.quantity * order_item.unit_price

    json.product_variant do
      json.id order_item.product_variant.id
      json.name order_item.product_variant.sku
      json.price order_item.product_variant.price
    end
  end
end



