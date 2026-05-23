# frozen_string_literal: true

module ExpenseSerializable
  extend ActiveSupport::Concern

  private

  def expense_json(expense)
    payment = expense.payment
    {
      id: expense.id,
      date: expense.date,
      description: expense.description,
      expense_type: expense.expense_type&.slice(:id, :name),
      payment: payment && {
        id: payment.id,
        amount: payment.amount,
        payment_mode: payment.payment_mode&.slice(:id, :name),
        bank_detail: payment.bank_detail&.slice(:id, :name)
      }
    }
  end

  def user_json(user)
    {
      id: user.id,
      email: user.email,
      role: user.role,
      role_label: user.role_label
    }
  end
end
