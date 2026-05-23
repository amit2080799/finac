# frozen_string_literal: true

module Api
  module V1
    class OptionsController < BaseController
      skip_authorization_check

      def show
        render json: {
          expense_types: ExpenseType.order(:name).select(:id, :name),
          payment_modes: PaymentMode.order(:name).select(:id, :name),
          bank_details: BankDetail.order(:name).select(:id, :name),
          assignable_roles: User.assignable_roles_for(current_user).map do |role|
            { value: role, label: User::ROLE_LABELS[role] }
          end
        }
      end
    end
  end
end
