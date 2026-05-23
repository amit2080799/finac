# frozen_string_literal: true

module Api
  module V1
    class DashboardsController < BaseController
      skip_authorization_check

      def show
        month = month_param
        recent = Expense.list_with_associations.in_month(month).limit(5)

        render json: {
          summary: Expense.month_summary(month),
          recent_expenses: recent.map { |expense| expense_json(expense) }
        }
      end

      private

      def month_param
        parse_month(params[:month]) || Date.current
      end

      def parse_month(value)
        return nil if value.blank?

        Date.strptime(value, '%Y-%m')
      rescue ArgumentError
        nil
      end
    end
  end
end
