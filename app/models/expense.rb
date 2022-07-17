# frozen_string_literal: true

# Expense model
class Expense < ApplicationRecord
  belongs_to :expense_type
  belongs_to :payment

  def self.create(data)
    data['expense_type_id'] = ExpenseType.find_by(expense_type: data['expense_type']).try(:id)
    data['payment_mode_id'] = PaymentMode.find_by(name: data['payment_mode_name']).try(:id)
    data['bank_detail_id'] = BankDetail.find_by(name: data['bank_name']).try(:id)

    Payment.create_payment(data).expenses.last
  end

  def self.construct_expense_data
    expenses = []
    all_expenses = Expense.all

    all_expenses.each_with_index do |expense, index|
      next if expense.date.nil? && expense.payment_id.nil? && expense.expense_type_id.nil?

      expenses[index] = {}
      expenses[index][:date] = expense.date
      expenses[index][:expense_type] = ExpenseType.find_by(id: expense.expense_type_id).try(:expense_type)
      payment = Payment.find_by(id: expense.payment_id)
      payment_mode_id = payment.try(:payment_mode_id)
      bank_detail_id = payment.try(:bank_detail_id)
      expenses[index][:payment_mode] = PaymentMode.find_by(id: payment_mode_id).try(:name)
      expenses[index][:bank_name] = BankDetail.find_by(id: bank_detail_id).try(:name)
      expenses[index][:amount] = payment.try(:amount)
      expenses[index][:description] = expense.try(:description)
      expenses[index][:id] = expense.try(:id)
    end
    expenses.compact.sort_by { |expense| expense['date'] }
  end

  def self.fetch_expense_data
    @expense_types = ExpenseType.all
    @payment_modes = PaymentMode.all
    @bank_details = BankDetail.all

    [@expense_types, @payment_modes, @bank_details]
  end
end
