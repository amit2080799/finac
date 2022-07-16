# frozen_string_literal: true

class PaymentMode < ApplicationRecord
  has_many :payments
end
