class User < ApplicationRecord
  has_secure_password

  has_many :addresses
  has_many :orders, dependent: :destroy
  has_one  :wishlist, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  
  enum :role, {
    customer: 0,
    admin: 1
  }, prefix: true
end
