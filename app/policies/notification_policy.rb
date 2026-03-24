# frozen_string_literal: true

class NotificationPolicy < ApplicationPolicy
  def index?
    true
  end

  def mark_read?
    record.recipient_id == user.id
  end

  def mark_all_read?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(recipient_id: user.id)
    end
  end
end
