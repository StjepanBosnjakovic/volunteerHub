class SwapRequestPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || own_request?
  end

  def create?
    admin? || volunteer?
  end

  def update?
    admin?
  end

  def approve?
    admin?
  end

  def decline?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(requested_by: user)
      end
    end
  end

  private

  def own_request?
    record.requested_by_id == user.id
  end
end
