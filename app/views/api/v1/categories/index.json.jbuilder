json.categories @categories do |category|
  json.id category.id
  json.name category.name
  json.description category.description
  json.slug category.slug
  json.parent_id category.parent_id
  json.status category.status
end