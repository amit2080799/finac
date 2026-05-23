# frozen_string_literal: true

module Api
  module V1
    class ExpensesController < BaseController
      load_and_authorize_resource

      def index
        expenses = Expense.list_with_associations
        expenses = expenses.in_month(month_param) if params[:month].present?
        expenses = expenses.page(params[:page]).per(per_page)

        render json: {
          expenses: expenses.map { |expense| expense_json(expense) },
          meta: pagination_meta(expenses)
        }
      end

      def show
        render json: { expense: expense_json(@expense) }
      end

      def create
        @expense = Expense.new(expense_params)

        if @expense.save
          render json: { expense: expense_json(@expense) }, status: :created
        else
          render json: { errors: @expense.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @expense.update(expense_params)
          render json: { expense: expense_json(@expense) }
        else
          render json: { errors: @expense.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @expense.destroy
        head :no_content
      end

      private

      def month_param
        Date.strptime(params[:month], '%Y-%m')
      rescue ArgumentError, TypeError
        Date.current
      end

      def per_page
        (params[:per_page] || 10).to_i.clamp(1, 50)
      end

      def expense_params
        params.require(:expense).permit(
          :date,
          :description,
          :expense_type_id,
          payment_attributes: %i[id amount payment_mode_id bank_detail_id]
        )
      end
    end
  end
end
