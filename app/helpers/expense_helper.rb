# frozen_string_literal: true

# ExpenseHelper module
module ExpenseHelper
  def all_expense_types
    ExpenseType.all
  end

  def all_payment_modes
    PaymentMode.all
  end

  def all_bank_details
    BankDetail.all
  end

  def construct_expense_data
    expenses = []

    @expenses.each_with_index do |expense, index|
      next if expense.date.nil? && expense.payment_id.nil? && expense.expense_type_id.nil?

      expenses[index] = {}.with_indifferent_access
      expenses[index]['date'] = expense.date
      expenses[index]['expense_type'] = ExpenseType.find_by(id: expense.expense_type_id).try(:expense_type)
      payment = Payment.find_by(id: expense.payment_id)
      payment_mode_id = payment.try(:payment_mode_id)
      bank_detail_id = payment.try(:bank_detail_id)
      expenses[index]['payment_mode'] = PaymentMode.find_by(id: payment_mode_id).try(:name)
      expenses[index]['bank_name'] = BankDetail.find_by(id: bank_detail_id).try(:name)
      expenses[index]['amount'] = payment.try(:amount)
    end
    expenses.compact.sort_by { |expense| expense['date'] }
  end
end
