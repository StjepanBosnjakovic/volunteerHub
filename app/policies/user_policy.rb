# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || own_record?
  end

  def update?
    super_admin? || own_record?
  end

  def destroy?
    super_admin? && !own_record?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def own_record?
    record.id == user.id
  end
end
