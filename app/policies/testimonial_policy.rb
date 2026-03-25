# frozen_string_literal: true

class TestimonialPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    admin? || record.published?
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

  def publish?
    admin? && record.consent_given?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.published
      end
    end
  end
end
