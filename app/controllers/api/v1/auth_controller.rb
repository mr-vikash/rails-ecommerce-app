class Api::V1::AuthController < ApplicationController

  def signup
    @user = User.new(user_params)
    if @user.save
      render :signup, status: :created
    else
      render json: { errors: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      render json: {
        user: {
          id: @user.id,
          name: @user.name,
          email: @user.email
        },
        token: token
      }, status: :ok
    else
      render json: { error: "Invalid Email or Password" }, status: :unauthorized
    end
  end


  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :role
    )
  end
end
