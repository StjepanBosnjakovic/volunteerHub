# frozen_string_literal: true

class OnboardingChecklistPolicy < ApplicationPolicy
  def index?
    staff_or_above? || volunteer?
  end

  def show?
    staff_or_above? || volunteer?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def cohort_dashboard?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
