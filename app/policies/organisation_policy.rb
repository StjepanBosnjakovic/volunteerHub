# frozen_string_literal: true

class OrganisationPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    super_admin?
  end

  def settings?
    super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(id: user.organisation_id)
    end
  end
end
