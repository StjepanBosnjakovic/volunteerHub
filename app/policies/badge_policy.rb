# frozen_string_literal: true

class BadgePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def update?
    admin?
  end

  def edit?
    update?
  end

  def destroy?
    super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Volunteers see all badges (system + org); admins see everything
      scope.where("organisation_id IS NULL OR organisation_id = ?",
                  user.organisation_id)
    end
  end
end
