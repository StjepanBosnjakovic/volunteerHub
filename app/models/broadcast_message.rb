class BroadcastMessage < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  belongs_to :sender, class_name: "User"

  enum :channel, { in_app: 0, email: 1, sms: 2, whatsapp: 3 }
  enum :status,  { draft: 0, sending: 1, sent: 2, failed: 3 }

  validates :subject,  presence: true
  validates :body,     presence: true
  validates :channel,  presence: true

  scope :ordered, -> { order(created_at: :desc) }

  def resolve_recipients
    filters = segment_filters || {}
    scope = organisation.users.includes(:volunteer_profile)

    scope = scope.where(role: filters["role"]) if filters["role"].present?

    if filters["program_id"].present?
      scope = scope.joins(volunteer_profile: :shift_assignments)
                   .joins("INNER JOIN shifts ON shifts.id = shift_assignments.shift_id")
                   .where(shifts: { program_id: filters["program_id"] })
                   .distinct
    end

    if filters["volunteer_status"].present?
      scope = scope.joins(:volunteer_profile)
                   .where(volunteer_profiles: { status: filters["volunteer_status"] })
    end

    scope
  end

  def send_broadcast!
    update!(status: :sending)
    BroadcastMessageJob.perform_later(id)
  end
end
