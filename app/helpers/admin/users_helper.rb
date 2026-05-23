# frozen_string_literal: true

module Admin
  module UsersHelper
    def role_badge_class(role)
      {
        'super_admin' => 'bg-danger',
        'admin' => 'bg-warning text-dark',
        'user' => 'bg-secondary'
      }.fetch(role, 'bg-light text-dark')
    end
  end
end
