# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :expense_type
  has_one :payment, dependent: :destroy

  accepts_nested_attributes_for :payment

  validates :date, presence: true
  validates :expense_type, presence: true
  validates :payment, presence: true

  scope :ordered, -> { order(date: :desc, created_at: :desc) }
  scope :in_month, lambda { |month = Date.current|
    where(date: month.beginning_of_month..month.end_of_month)
  }

  def self.list_with_associations
    includes(:expense_type, payment: %i[payment_mode bank_detail]).ordered
  end

  def self.month_summary(month = Date.current)
    expenses = list_with_associations.in_month(month)
    payments = expenses.map(&:payment).compact
    amounts_by_type = expenses.each_with_object(Hash.new(0.to_d)) do |expense, totals|
      next unless expense.payment && expense.expense_type

      totals[expense.expense_type.name] += expense.payment.amount.to_d
    end

    {
      total_expenses: payments.sum { |payment| payment.amount.to_d },
      transactions_count: expenses.size,
      latest_expense_date: expenses.maximum(:date),
      top_category: amounts_by_type.max_by { |_name, amount| amount }&.first
    }
  end
end
