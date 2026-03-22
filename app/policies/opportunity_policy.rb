# frozen_string_literal: true

class OpportunityPolicy < ApplicationPolicy
  def index?
    true  # public
  end

  def show?
    true  # public
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_volunteer?
        scope.published
      else
        scope.all
      end
    end
  end
end
