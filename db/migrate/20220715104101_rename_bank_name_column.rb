# frozen_string_literal: true

# migration to rename column bank_name to name
class RenameBankNameColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :bank_details, :bank_name, :name
  end
end
