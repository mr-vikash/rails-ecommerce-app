class Notification < ApplicationRecord
  belongs_to :user

  validates :notification_type, :title, :message, presence: true
end
