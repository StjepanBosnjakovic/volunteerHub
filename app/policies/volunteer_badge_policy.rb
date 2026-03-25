# frozen_string_literal: true

class VolunteerBadgePolicy < ApplicationPolicy
  def create?
    admin?
  end

  def destroy?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:volunteer_profile)
           .where(volunteer_profiles: { organisation_id: user.organisation_id })
    end
  end
end
