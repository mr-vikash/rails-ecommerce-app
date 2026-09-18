json.status "success"

json.product_variant do
  json.id @product_variant.id
  json.product_id @product_variant.product_id
  json.sku @product_variant.sku
  json.price @product_variant.price
  json.stock_quantity @product_variant.stock_quantity
  json.size @product_variant.size
  json.color @product_variant.color
  json.status @product_variant.status
end