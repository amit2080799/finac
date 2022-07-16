# frozen_string_literal: true

# Payment model
class Payment < ApplicationRecord
  has_many :expenses

  belongs_to :payment_mode
  belongs_to :bank_detail

  accepts_nested_attributes_for :expenses

  def self.create_payment(data)
    params = {
      payment: {
        bank_detail_id: data['bank_detail_id'],
        payment_mode_id: data['payment_mode_id'],
        amount: data['amount'],
        expenses_attributes: [{
          date: data['date'],
          expense_type_id: data['expense_type_id'],
          description: data['description']
        }]
      }
    }.with_indifferent_access
    Payment.create(params['payment'])
  end
end
