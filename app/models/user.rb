# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = {
    super_admin: 'super_admin',
    admin: 'admin',
    user: 'user'
  }.freeze

  ROLE_LABELS = {
    'super_admin' => 'Super Admin',
    'admin' => 'Admin',
    'user' => 'User'
  }.freeze

  ROLE_PRIORITY = %w[user admin super_admin].freeze

  enum role: ROLES

  validates :role, inclusion: { in: ROLES.values }

  scope :ordered_by_role, -> { order(Arel.sql("array_position(ARRAY['super_admin','admin','user']::varchar[], role)")) }

  def role_label
    ROLE_LABELS[role] || role.titleize
  end

  def super_admin?
    role == ROLES[:super_admin]
  end

  def admin?
    role == ROLES[:admin]
  end

  def at_least_admin?
    super_admin? || admin?
  end

  def self.assignable_roles_for(assigner)
    return ROLES.values if assigner&.super_admin?
    return [ROLES[:admin], ROLES[:user]] if assigner&.admin?

    []
  end

  def assignable_by?(assigner)
    return false if assigner.blank?
    return true if assigner.super_admin?
    return false if super_admin?

    assigner.admin? && assigner.id != id
  end

  def role_assignable_by?(assigner, new_role)
    return false unless assignable_by?(assigner)
    return false if new_role == ROLES[:super_admin] && !assigner.super_admin?

    self.class.assignable_roles_for(assigner).include?(new_role)
  end
end
