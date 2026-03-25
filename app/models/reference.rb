class Reference < ApplicationRecord
  belongs_to :volunteer_profile
  belongs_to :coordinator, class_name: "User"
  has_one_attached :pdf_document

  enum :status, { requested: 0, issued: 1, declined: 2 }

  validates :volunteer_profile, presence: true
  validates :coordinator,       presence: true

  scope :ordered, -> { order(created_at: :desc) }

  def build_stats_snapshot!
    profile = volunteer_profile
    update!(stats_snapshot: {
      total_hours:    profile.total_approved_hours,
      shifts_attended: profile.shift_assignments.where(status: :confirmed).count,
      badges_earned:  profile.volunteer_badges.count,
      programs:       profile.hour_logs.approved.joins(:program).distinct.pluck("programs.name"),
      snapshot_at:    Time.current.iso8601
    })
  end

  def issue!(coordinator:)
    build_stats_snapshot!
    update!(status: :issued, issued_at: Time.current, coordinator: coordinator)
  end
end
