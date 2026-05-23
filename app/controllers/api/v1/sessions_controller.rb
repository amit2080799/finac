# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      include ExpenseSerializable

      skip_before_action :authenticate_user!
      skip_authorization_check
      skip_before_action :verify_authenticity_token

      def show
        if user_signed_in?
          render json: { user: user_json(current_user) }
        else
          render json: { user: nil }, status: :unauthorized
        end
      end

      def create
        user = User.find_by(email: session_params[:email]&.downcase)

        if user&.valid_password?(session_params[:password])
          sign_in(user)
          render json: { user: user_json(user) }
        else
          render json: { error: 'Invalid email or password.' }, status: :unauthorized
        end
      end

      def destroy
        sign_out(current_user) if user_signed_in?
        head :no_content
      end

      private

      def session_params
        params.require(:session).permit(:email, :password)
      end
    end
  end
end
