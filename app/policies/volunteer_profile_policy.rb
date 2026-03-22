# frozen_string_literal: true

class VolunteerProfilePolicy < ApplicationPolicy
  def index?
    staff_or_above?
  end

  def show?
    staff_or_above? || own_profile?
  end

  def create?
    admin? || volunteer?
  end

  def update?
    admin? || own_profile?
  end

  def destroy?
    super_admin?
  end

  def archive?
    admin?
  end

  def merge?
    admin?
  end

  def export_pdf?
    staff_or_above? || own_profile?
  end

  def import?
    admin?
  end

  def export_csv?
    admin?
  end

  def gdpr_erase?
    super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_super_admin? || user.role_coordinator? || user.role_read_only_staff?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  private

  def own_profile?
    record.user_id == user.id
  end
end
