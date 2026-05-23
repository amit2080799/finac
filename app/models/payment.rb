# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :expense
  belongs_to :payment_mode
  belongs_to :bank_detail

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_mode, :bank_detail, presence: true
end
