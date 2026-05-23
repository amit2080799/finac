# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class DashboardsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = User.create!(
          email: 'dashboard@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          role: :user
        )
        sign_in @user

        expense_type = ExpenseType.create!(name: 'fuel')
        payment_mode = PaymentMode.create!(name: 'Cash')
        bank = BankDetail.create!(name: 'HDFC')

        expense = Expense.create!(
          date: Date.current,
          description: 'Test fuel',
          expense_type: expense_type,
          payment_attributes: {
            amount: 100,
            payment_mode: payment_mode,
            bank_detail: bank
          }
        )
        @expense = expense
      end

      test 'returns dashboard payload' do
        get api_v1_dashboard_url
        assert_response :success

        body = JSON.parse(response.body)
        assert body['summary']
        assert body.key?('recent_expenses')
      end
    end
  end
end
