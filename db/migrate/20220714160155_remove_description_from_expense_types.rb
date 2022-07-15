# frozen_string_literal: true

# migration to remove column description from Expenses
class RemoveDescriptionFromExpenseTypes < ActiveRecord::Migration[7.0]
  def change
    remove_column :expense_types, :description, :string
  end
end
