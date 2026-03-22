# frozen_string_literal: true

class CredentialPolicy < ApplicationPolicy
  def index?
    staff_or_above? || own_profile?
  end

  def show?
    staff_or_above? || own_profile?
  end

  def create?
    admin? || own_profile?
  end

  def update?
    admin? || own_profile?
  end

  def destroy?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_super_admin? || user.role_coordinator? || user.role_read_only_staff?
        scope.all
      else
        scope.joins(:volunteer_profile).where(volunteer_profiles: { user_id: user.id })
      end
    end
  end

  private

  def own_profile?
    record.volunteer_profile.user_id == user.id
  end
end
