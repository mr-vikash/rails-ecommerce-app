json.status "success"
json.message "Product loaded successfully"

json.product do
  json.id @product.id
  json.name @product.name
  json.description @product.description
  json.sku @product.sku
  json.price @product.price
  json.discount_price @product.discount_price
  json.brand @product.brand
  json.weight @product.weight
  json.status @product.status

  json.category do
    json.id @product.category.id
    json.name @product.category.name
    json.description @product.category.description
    json.slug @product.category.slug
  end

  json.product_variants @product.product_variants do |variant|
    json.id variant.id
    json.sku variant.sku
    json.price variant.price
    json.stock_quantity variant.stock_quantity
    json.size variant.size
    json.color variant.color
    json.status variant.status
  end
end