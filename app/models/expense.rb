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

  def self.construct_expense_data
    expenses = []

    Expense.includes(:payment).each_with_index do |expense, index|
      payment = expense.payment
      next if expense.date.nil? && payment.id.nil? && expense.expense_type_id.nil?

      expenses[index] = {}
      expenses[index][:date] = expense.date
      expenses[index][:expense_type] = ExpenseType.find_by(id: expense.expense_type_id).try(:name)
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
