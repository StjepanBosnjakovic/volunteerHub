# frozen_string_literal: true

class EmailCampaignPolicy < ApplicationPolicy
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
    admin? && !record.sent?
  end

  def edit?
    update?
  end

  def destroy?
    admin? && record.draft?
  end

  def send_campaign?
    admin? && record.draft?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
