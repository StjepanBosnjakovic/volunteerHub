# frozen_string_literal: true

class SurveyPolicy < ApplicationPolicy
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
    admin?
  end

  def edit?
    update?
  end

  def destroy?
    admin?
  end

  def dashboard?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(organisation_id: user.organisation_id)
    end
  end
end
