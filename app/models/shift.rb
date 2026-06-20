class Shift < ApplicationRecord
  belongs_to :program
  belongs_to :coordinator, class_name: "User", optional: true
  has_many :shift_roles, dependent: :destroy
  has_many :shift_assignments, dependent: :destroy
  has_many :volunteer_profiles, through: :shift_assignments

  accepts_nested_attributes_for :shift_roles, allow_destroy: true, reject_if: :all_blank

  before_create :generate_qr_token

  validates :title, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :program, presence: true
  validate :ends_after_starts

  scope :upcoming, -> { where("starts_at > ?", Time.current) }
  scope :past, -> { where("ends_at < ?", Time.current) }
  scope :for_program, ->(program_id) { where(program_id: program_id) }
  scope :ordered, -> { order(:starts_at) }

  delegate :organisation, to: :program

  def confirmed_count
    shift_assignments.confirmed.count
  end

  def waitlisted_count
    shift_assignments.waitlisted.count
  end

  def spots_remaining
    return Float::INFINITY if capacity.nil?
    [capacity - confirmed_count, 0].max
  end

  def full?
    capacity.present? && spots_remaining == 0
  end

  def signup_open_for?(volunteer_profile)
    return false if full? && !waitlist_enabled
    !shift_assignments.where(volunteer_profile: volunteer_profile).exists?
  end

  def late_cancellation?(cancelled_at)
    cancellation_cutoff_hours.present? &&
      starts_at - cancelled_at < cancellation_cutoff_hours.hours
  end

  def duration_hours
    ((ends_at - starts_at) / 3600.0).round(2)
  end

  def qr_checkin_url
    host = ENV.fetch("APP_HOST", "localhost")
    Rails.application.routes.url_helpers.checkin_shift_url(qr_token: qr_token, host: host)
  rescue StandardError
    nil
  end

  # Generate recurring shift instances from RRULE (simple daily/weekly implementation)
  def generate_occurrences(limit: 10)
    return [self] if recurrence_rule.blank?
    occurrences = []
    duration = ends_at - starts_at
    current = starts_at
    rule_params = parse_rrule(recurrence_rule)
    count = 0
    while count < limit
      occurrences << current
      current = advance_by_rule(current, rule_params)
      count += 1
    end
    occurrences.map do |dt|
      Shift.new(
        program: program,
        coordinator: coordinator,
        title: title,
        location: location,
        lat: lat,
        lng: lng,
        starts_at: dt,
        ends_at: dt + duration,
        capacity: capacity,
        waitlist_enabled: waitlist_enabled,
        notes: notes
      )
    end
  end

  private

  def generate_qr_token
    self.qr_token ||= SecureRandom.urlsafe_base64(16)
  end

  def ends_after_starts
    return unless starts_at && ends_at
    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end

  def parse_rrule(rule)
    params = {}
    rule.split(";").each do |part|
      k, v = part.split("=")
      params[k.downcase.to_sym] = v
    end
    params
  end

  def advance_by_rule(dt, params)
    interval = (params[:interval] || "1").to_i
    case params[:freq]&.downcase
    when "daily"
      dt + interval.days
    when "weekly"
      dt + interval.weeks
    when "monthly"
      dt + interval.months
    else
      dt + 1.week
    end
  end
end
