class MilestonePolicy < ApplicationPolicy
  def index?   = staff_or_above?
  def show?    = staff_or_above?
  def create?  = admin?
  def update?  = admin?
  def destroy? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
