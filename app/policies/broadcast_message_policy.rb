# frozen_string_literal: true

class BroadcastMessagePolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def update?
    admin? && record.draft?
  end

  def edit?
    update?
  end

  def destroy?
    admin? && record.draft?
  end

  def send_broadcast?
    admin? && record.draft?
  end

  def preview_segment?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
