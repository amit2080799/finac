# frozen_string_literal: true

# migration to create BankDetails
class CreateBankDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_details do |t|
      t.string :bank_name, null: false

      t.timestamps
    end
  end
end
