# frozen_string_literal: true

# migration to create Expenses
class CreateExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :expenses do |t|
      t.integer :expense_type_id
      t.date :date

      t.timestamps
    end
    add_foreign_key :expenses, :expense_types, index: true
  end
end
