# frozen_string_literal: true

# migration to create Payments
class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.decimal :amount, precision: 8, scale: 2

      t.timestamps
    end

    add_reference :payments, :payment_mode, index: true
    add_reference :payments, :bank_detail, index: true
    add_reference :payments, :expense, index: true
  end
end
