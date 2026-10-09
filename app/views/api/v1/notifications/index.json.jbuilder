json.status "success"
json.message "Notifications loaded successfully"

json.notifications @notifications do |notification|
  json.id notification.id
  json.notification_type notification.notification_type
  json.title notification.title
  json.message notification.message
  json.read_at notification.read_at
  json.read notification.read_at.present?
  json.created_at notification.created_at
end