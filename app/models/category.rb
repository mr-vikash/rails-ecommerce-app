class Category < ApplicationRecord
  has_many :products

  belongs_to :parent, class_name: "Category", optional: true
end
