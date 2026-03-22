class ShiftAssignmentPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def create?
    # Admins can assign anyone; volunteers can sign themselves up
    admin? || (volunteer? && own_profile?)
  end

  def destroy?
    admin? || own_assignment?
  end

  def update?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        profile = user.volunteer_profile
        scope.where(volunteer_profile: profile)
      end
    end
  end

  private

  def own_profile?
    record.volunteer_profile_id == user.volunteer_profile&.id
  end

  def own_assignment?
    record.volunteer_profile_id == user.volunteer_profile&.id
  end
end
