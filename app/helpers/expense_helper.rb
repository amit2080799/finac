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
end
