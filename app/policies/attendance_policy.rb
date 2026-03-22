class AttendancePolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def checkin?
    true  # Any authenticated user can use QR check-in
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
