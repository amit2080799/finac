# frozen_string_literal: true

json.extract! expense, :id, :created_at, :updated_at, :description, :expense_type_id, :date
json.url expense_url(expense, format: :json)
