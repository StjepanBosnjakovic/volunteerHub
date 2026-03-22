# frozen_string_literal: true

class VolunteerApplicationPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || own_application?
  end

  def create?
    volunteer? || admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_volunteer? && user.volunteer_profile.present?
        scope.where(volunteer_profile: user.volunteer_profile)
      else
        scope.all
      end
    end
  end

  private

  def own_application?
    record.volunteer_profile_id == user.volunteer_profile&.id
  end
end
