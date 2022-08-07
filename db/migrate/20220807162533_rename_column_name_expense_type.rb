# frozen_string_literal: true

# Migration to rename column name
class RenameColumnNameExpenseType < ActiveRecord::Migration[7.0]
  def change
    rename_column :expense_types, :expense_type, :name
  end
end
