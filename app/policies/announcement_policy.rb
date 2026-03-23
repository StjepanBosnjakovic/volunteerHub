# frozen_string_literal: true

class AnnouncementPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    admin? || (record.published? && record.published_at <= Time.current)
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def update?
    admin? && !record.archived?
  end

  def edit?
    update?
  end

  def destroy?
    admin?
  end

  def publish?
    admin? && (record.draft? || record.scheduled?)
  end

  def schedule_send?
    admin? && record.draft?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.visible
      end
    end
  end
end
