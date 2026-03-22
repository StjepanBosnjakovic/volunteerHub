# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

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
    super_admin?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end

  private

  def super_admin?
    user.role_super_admin?
  end

  def coordinator?
    user.role_coordinator?
  end

  def read_only_staff?
    user.role_read_only_staff?
  end

  def volunteer?
    user.role_volunteer?
  end

  def admin?
    super_admin? || coordinator?
  end

  def staff_or_above?
    super_admin? || coordinator? || read_only_staff?
  end
end
