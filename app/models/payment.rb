# frozen_string_literal: true

class Payment < ApplicationRecord
  has_many :expenses

  belongs_to :payment_mode
  belongs_to :bank_detail
end
