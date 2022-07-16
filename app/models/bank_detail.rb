# frozen_string_literal: true

class BankDetail < ApplicationRecord
  has_many :payments
end
