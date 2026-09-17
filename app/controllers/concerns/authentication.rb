module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
  end

  def authenticate_user
    token = request.headers['Authorization']&.split(" ")&.last

    if token.blank?
      render json: { error: "Authentication token is required"},
             status: :unauthorized
      return
    end

    decoded_token = JsonWebToken.decode(token)
    @current_user = User.find(decoded_token[0]['user_id'])
  rescue JWT::DecodeError
    render json: { error: "Invalid or Expired Token"},
           status: :unauthorized
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found"},
           status: :unauthorized
  end

  def current_user
    @current_user
  end
end