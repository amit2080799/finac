# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      load_and_authorize_resource class: User

      def index
        users = @users.order(:email).page(params[:page]).per(per_page)
        render json: {
          users: users.map { |user| user_json(user) },
          meta: pagination_meta(users),
          assignable_roles: role_options
        }
      end

      def show
        render json: {
          user: user_json(@user),
          assignable_roles: role_options
        }
      end

      def create
        @user = User.new(user_params)

        unless role_allowed?(@user.role)
          return render json: { errors: ['Role is not allowed'] }, status: :unprocessable_entity
        end

        if @user.save
          render json: { user: user_json(@user) }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        unless @user.assignable_by?(current_user)
          return render json: { error: 'You cannot modify this user.' }, status: :forbidden
        end

        unless role_allowed?(user_params[:role])
          return render json: { errors: ['Role is not allowed'] }, status: :unprocessable_entity
        end

        if @user.update(user_params)
          render json: { user: user_json(@user) }
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @user == current_user
          render json: { error: 'You cannot delete your own account.' }, status: :unprocessable_entity
        elsif @user.destroy
          head :no_content
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        permitted = params.require(:user).permit(:email, :password, :password_confirmation, :role)
        if permitted[:password].blank?
          permitted.delete(:password)
          permitted.delete(:password_confirmation)
        end
        permitted
      end

      def role_options
        User.assignable_roles_for(current_user).map do |role|
          { value: role, label: User::ROLE_LABELS[role] }
        end
      end

      def role_allowed?(role)
        return true if role.blank?

        User.assignable_roles_for(current_user).include?(role)
      end

      def per_page
        (params[:per_page] || 10).to_i.clamp(1, 50)
      end
    end
  end
end
