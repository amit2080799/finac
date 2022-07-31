# frozen_string_literal: true

# Payment model
class Payment < ApplicationRecord
  belongs_to :expense
  belongs_to :payment_mode
  belongs_to :bank_detail
end
