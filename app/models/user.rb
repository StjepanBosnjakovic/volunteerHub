class User < ApplicationRecord
  acts_as_tenant :organisation

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable

  enum :role, { super_admin: 0, coordinator: 1, read_only_staff: 2, volunteer: 3 }, prefix: true

  belongs_to :organisation
  has_one :volunteer_profile, dependent: :destroy
  has_many :coordinator_programs, dependent: :destroy

  validates :role, presence: true

  scope :coordinators, -> { where(role: :coordinator) }
  scope :volunteers, -> { where(role: :volunteer) }

  def display_name
    volunteer_profile&.full_name || email
  end

  def admin?
    role_super_admin? || role_coordinator?
  end
end
