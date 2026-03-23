class EmailCampaign < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  belongs_to :sender, class_name: "User"

  enum :status, { draft: 0, sending: 1, sent: 2, cancelled: 3 }

  validates :name,      presence: true
  validates :subject_a, presence: true
  validates :body_html, presence: true
  validates :channel,   presence: true

  scope :ordered, -> { order(created_at: :desc) }

  def ab_test?
    subject_b.present?
  end

  def open_rate_a
    return 0 if recipient_count.zero?

    total_a = ab_test? ? (recipient_count / 2.0).ceil : recipient_count
    return 0 if total_a.zero?

    (open_count_a.to_f / total_a * 100).round(1)
  end

  def open_rate_b
    return 0 unless ab_test? && recipient_count > 0

    total_b = (recipient_count / 2.0).floor
    return 0 if total_b.zero?

    (open_count_b.to_f / total_b * 100).round(1)
  end

  def winning_variant
    return "A" unless ab_test?

    open_rate_a >= open_rate_b ? "A" : "B"
  end

  def segment_summary
    filters = segment_filters || {}
    parts = []
    parts << "Role: #{filters['role']}"              if filters["role"].present?
    parts << "Program: #{filters['program_id']}"     if filters["program_id"].present?
    parts << "Status: #{filters['volunteer_status']}" if filters["volunteer_status"].present?
    parts.empty? ? "All volunteers" : parts.join(", ")
  end
end
