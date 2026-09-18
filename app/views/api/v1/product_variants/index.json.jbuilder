json.product_variants @product_variants do |variant|
  json.id variant.id
  json.product_id variant.product_id
  json.sku variant.sku
  json.price variant.price
  json.stock_quantity variant.stock_quantity
  json.size variant.size
  json.color variant.color
  json.status variant.status
end

json.message "Product variants loaded successfully"
json.status "success"
