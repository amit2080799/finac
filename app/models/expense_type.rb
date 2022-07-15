# frozen_string_literal: true

class ExpenseType < ApplicationRecord
  has_many :expenses
end
