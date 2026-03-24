# frozen_string_literal: true

class ConversationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    participant?
  end

  def create?
    true
  end

  def new?
    create?
  end

  def destroy?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.for_user(user)
    end
  end

  private

  def participant?
    record.conversation_participants.exists?(user_id: user.id) || admin?
  end
end
