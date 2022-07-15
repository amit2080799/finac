# frozen_string_literal: true

# migration to add column description to Expenses
class AddDescriptionToExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :expenses, :description, :string
  end
end
