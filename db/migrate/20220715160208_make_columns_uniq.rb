# frozen_string_literal: true

# migration to add uniq to columns
class MakeColumnsUniq < ActiveRecord::Migration[7.0]
  def change
    add_index :payment_modes, :name, unique: true
    add_index :bank_details, :name, unique: true
    add_index :expense_types, :expense_type, unique: true
  end
end
