class HourLogPolicy < ApplicationPolicy
  # Volunteers see only their own; admins see all within org
  def index?
    true
  end

  def show?
    admin? || own_record?
  end

  def create?
    true  # volunteers can self-log; admins can log on behalf
  end

  def update?
    admin?
  end

  def approve?
    admin?
  end

  def reject?
    admin?
  end

  def dispute?
    own_record?
  end

  def bulk_import?
    admin?
  end

  def export?
    staff_or_above? || own_record?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_volunteer? && user.volunteer_profile
        scope.where(volunteer_profile: user.volunteer_profile)
      else
        scope.all
      end
    end
  end

  private

  def own_record?
    record.is_a?(HourLog) && user.volunteer_profile &&
      record.volunteer_profile_id == user.volunteer_profile.id
  end
end
