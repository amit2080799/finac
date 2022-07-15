# frozen_string_literal: true

json.extract! expense, :id, :created_at, :updated_at
json.url expense_url(expense, format: :json)
