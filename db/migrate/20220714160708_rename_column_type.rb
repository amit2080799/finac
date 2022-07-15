# frozen_string_literal: true

# migration to rename column type to expense_type
class RenameColumnType < ActiveRecord::Migration[7.0]
  def change
    rename_column :expense_types, :type, :expense_type
  end
end
