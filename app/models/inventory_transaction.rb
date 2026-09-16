class InventoryTransaction < ApplicationRecord
  belongs_to :product_variant

  belongs_to :reference, polymorphic: true, optional: true

  validates :transaction_type, :quantity, presence: true
end
