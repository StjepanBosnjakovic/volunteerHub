class VolunteerProfile < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :user
  belongs_to :organisation

  has_many :volunteer_skills, dependent: :destroy
  has_many :skills, through: :volunteer_skills
  has_many :volunteer_interests, dependent: :destroy
  has_many :interest_categories, through: :volunteer_interests
  has_many :availabilities, dependent: :destroy
  has_many :blackout_dates, dependent: :destroy
  has_many :emergency_contacts, dependent: :destroy
  has_many :custom_field_values, as: :customizable, dependent: :destroy
  has_many :credentials, dependent: :destroy
  has_many :volunteer_applications, dependent: :destroy
  has_many :applied_opportunities, through: :volunteer_applications, source: :opportunity
  has_many :volunteer_onboarding_progresses, dependent: :destroy
  has_many :quiz_answers, dependent: :destroy

  # Phase 3: Scheduling
  has_many :shift_assignments, dependent: :destroy
  has_many :confirmed_shifts, -> { merge(ShiftAssignment.confirmed) }, through: :shift_assignments, source: :shift
  has_many :waitlisted_shifts, -> { merge(ShiftAssignment.waitlisted) }, through: :shift_assignments, source: :shift

  has_one_attached :avatar

  enum :status, { pending: 0, active: 1, inactive: 2 }, prefix: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :status, presence: true

  before_save :set_minor_flag, if: -> { date_of_birth.present? }

  scope :active, -> { where(status: :active) }
  scope :pending, -> { where(status: :pending) }
  scope :minors, -> { where(is_minor: true) }

  def full_name
    [preferred_name.presence || first_name, last_name].join(" ")
  end

  def age
    return nil unless date_of_birth
    today = Date.current
    years = today.year - date_of_birth.year
    years -= 1 if today < date_of_birth + years.years
    years
  end

  def minor?
    is_minor
  end

  def anonymize!
    update!(
      first_name: "REDACTED",
      last_name: "REDACTED",
      preferred_name: nil,
      pronouns: nil,
      date_of_birth: nil,
      phone: nil,
      bio: nil
    )
    emergency_contacts.destroy_all
  end

  private

  def set_minor_flag
    self.is_minor = age < 18 if date_of_birth.present?
  end
end
