# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.super_admin?
      can :manage, :all
    elsif user.admin?
      can :manage, Expense
      can :manage, User
      cannot :manage, User, role: User::ROLES[:super_admin]
      cannot %i[create update destroy], User, id: user.id
    elsif user.persisted?
      can :manage, Expense
      can %i[read update], User, id: user.id
    end
  end
end
