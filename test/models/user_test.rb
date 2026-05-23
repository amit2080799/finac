# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'assignable roles for super admin' do
    super_admin = User.new(role: :super_admin)
    assert_equal User::ROLES.values, User.assignable_roles_for(super_admin)
  end

  test 'assignable roles for admin excludes super admin' do
    admin = User.new(role: :admin)
    assert_equal %w[admin user], User.assignable_roles_for(admin)
  end

  test 'admin cannot assign super admin role' do
    admin = User.new(role: :admin)
    target = User.new(role: :user)

    assert_not target.role_assignable_by?(admin, 'super_admin')
    assert target.role_assignable_by?(admin, 'user')
  end
end
