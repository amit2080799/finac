# frozen_string_literal: true

# Expense model
class Expense < ApplicationRecord
  has_one :payment, dependent: :destroy
  belongs_to :expense_type

  accepts_nested_attributes_for :payment

  def create_expense(data)
    data = fetch_associated_data(data)
    create_expense_data(data)
  end

  def update_expense(data)
    data = fetch_associated_data(data)
    update_expense_data(data)
  end

  def self.fetch_expenses
    Expense.includes({ payment: %i[bank_detail payment_mode] }, :expense_type)
  end

  def fetch_expense_data
    @expense_types = ExpenseType.all
    @payment_modes = PaymentMode.all
    @bank_details = BankDetail.all

    [@expense_types, @payment_modes, @bank_details]
  end

  def create_expense_data(data)
    expense = construct_expense_params(data)
    Expense.create(expense)
  end

  def update_expense_data(data)
    expense = construct_expense_params(data)
    update(expense)
  end

  def construct_expense_params(data)
    {
      date: data['date'],
      expense_type_id: data['expense_type_id'],
      description: data['description'],
      payment_attributes: {
        bank_detail_id: data['bank_detail_id'],
        payment_mode_id: data['payment_mode_id'],
        amount: data['amount']
      }
    }.with_indifferent_access
  end

  def fetch_associated_data(data)
    data['expense_type_id'] = ExpenseType.find_by(name: data['expense_type']).try(:id)
    data['payment_mode_id'] = PaymentMode.find_by(name: data['payment_mode']).try(:id)
    data['bank_detail_id'] = BankDetail.find_by(name: data['bank_name']).try(:id)
    data
  end
end
