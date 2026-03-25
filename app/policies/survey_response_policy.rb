# frozen_string_literal: true

class SurveyResponsePolicy < ApplicationPolicy
  def create?
    # Volunteers can submit survey responses
    volunteer? || admin?
  end

  def new?
    create?
  end

  def show?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:survey)
           .where(surveys: { organisation_id: user.organisation_id })
    end
  end
end
