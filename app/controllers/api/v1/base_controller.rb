# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include ExpenseSerializable

      skip_before_action :verify_authenticity_token
      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        return if user_signed_in?

        render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
