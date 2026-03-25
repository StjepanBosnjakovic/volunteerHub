# frozen_string_literal: true

class ReferencePolicy < ApplicationPolicy
  def index?
    admin? || own_profile?
  end

  def show?
    admin? || own_profile?
  end

  def create?
    admin? || own_profile?
  end

  def new?
    create?
  end

  def issue?
    admin? && record.requested?
  end

  def decline?
    admin? && record.requested?
  end

  def export_pdf?
    show?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.joins(:volunteer_profile)
             .where(volunteer_profiles: { organisation_id: user.organisation_id })
      else
        scope.joins(:volunteer_profile)
             .where(volunteer_profiles: { user_id: user.id })
      end
    end
  end

  private

  def own_profile?
    record.is_a?(Reference) ?
      record.volunteer_profile.user_id == user.id :
      false
  end
end
