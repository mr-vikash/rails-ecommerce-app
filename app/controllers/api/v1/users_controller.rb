module Api::V1
  class UsersController < ApplicationController
    def index
      render json: {"vikash": "Gupta"}
    end
  end
end
