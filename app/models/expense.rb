# frozen_string_literal: true

# Expense model
class Expense < ApplicationRecord
  belongs_to :expense_type
  belongs_to :payment

  def self.create_expense(data)
    expense_type_id = ExpenseType.find_by(expense_type: data['expense_type']).try(:id)
    payment_mode_id = PaymentMode.find_by(name: data['payment_mode_name']).try(:id)
    bank_detail_id = BankDetail.find_by(name: data['bank_name']).try(:id)

    payment = create_payment(payment_mode_id, bank_detail_id, data['amount'])
    Expense.new({
                  date: data['date'],
                  payment_id: payment.id,
                  expense_type_id: expense_type_id,
                  description: data['description']
                })
  end

  def self.create_payment(payment_mode_id, bank_detail_id, amount)
    Payment.create({
                     bank_detail_id: bank_detail_id,
                     payment_mode_id: payment_mode_id,
                     amount: amount
                   })
  end
end
