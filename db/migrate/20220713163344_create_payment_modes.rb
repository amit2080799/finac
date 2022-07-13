# frozen_string_literal: true

# migration to create PaymentModes
class CreatePaymentModes < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_modes do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
