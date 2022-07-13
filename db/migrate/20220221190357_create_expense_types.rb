# frozen_string_literal: true

# migration to create ExpenseTypes
class CreateExpenseTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :expense_types do |t|
      t.string :type, null: false
      t.text :description

      t.timestamps
    end
  end
end
