# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    record.sender_id == user.id || admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:conversation)
           .joins("INNER JOIN conversation_participants cp ON cp.conversation_id = conversations.id AND cp.user_id = #{user.id}")
    end
  end
end
