json.status "success"
json.message "Product images loaded successfully"

json.product_images @product_images do |product_image|
  json.id product_image.id
  json.product_id product_image.product_id
  json.position product_image.position

  if product_image.image.attached?
    json.image_url url_for(product_image.image)
  else
    json.image_url nil
  end

  json.created_at product_image.created_at
  json.updated_at product_image.updated_at
end