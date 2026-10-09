class Api::V1::NotificationsController < ApplicationController
      include Authentication

      before_action :set_notification, only: [:show, :read]

      def index
        @notifications = current_user.notifications.order(created_at: :desc)

        render :index, status: :ok
      end

      def show
        render :show, status: :ok
      end

  def read
    @notification.update!(read_at: Time.current)

    render json: {
      status: "success",
      message: "Notification marked as read",
      notification_id: @notification.id,
      read_at: @notification.read_at
    }, status: :ok
  end

  def read_all
    current_user.notifications
                .where(read_at: nil)
                .update_all(read_at: Time.current, updated_at: Time.current)

    render json: {
      status: "success",
      message: "All notifications marked as read"
    }, status: :ok
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
