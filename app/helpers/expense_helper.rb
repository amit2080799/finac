# frozen_string_literal: true

# ExpenseHelper module
module ExpenseHelper
  def fetch_expense_types
    @expense_types.map(&:name)
  end

  def fetch_payment_modes
    @payment_modes.map(&:name)
  end

  def fetch_bank_names
    @bank_details.map(&:name)
  end
end
