class Notification < ApplicationRecord
  belongs_to :user

  validates :notification_type, :title, :message, presence: true
  belongs_to :payment, optional: true
end
