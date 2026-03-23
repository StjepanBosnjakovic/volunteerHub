class EmailTemplate < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation

  EVENT_TYPES = %w[
    welcome
    application_received
    application_approved
    application_declined
    shift_reminder
    shift_cancelled
    onboarding_reminder
    hour_approved
    hour_rejected
    milestone_reached
    credential_expiry
    password_reset
    broadcast
  ].freeze

  validates :event_type, presence: true, inclusion: { in: EVENT_TYPES }
  validates :event_type, uniqueness: { scope: :organisation_id }
  validates :subject,    presence: true
  validates :body_html,  presence: true

  scope :active,   -> { where(active: true) }
  scope :ordered,  -> { order(event_type: :asc) }

  PERSONALISATION_TOKENS = {
    "{{volunteer_name}}"   => "Volunteer's full name",
    "{{org_name}}"         => "Organisation name",
    "{{shift_title}}"      => "Shift title",
    "{{shift_date}}"       => "Shift start date/time",
    "{{program_name}}"     => "Program name",
    "{{hours}}"            => "Number of hours",
    "{{milestone_label}}"  => "Milestone label",
    "{{credential_name}}"  => "Credential name",
    "{{days_until_expiry}}" => "Days until credential expires",
    "{{dashboard_link}}"   => "Link to volunteer dashboard",
    "{{unsubscribe_link}}" => "Unsubscribe link"
  }.freeze

  def interpolate(context = {})
    body = body_html.dup
    subject_text = subject.dup

    PERSONALISATION_TOKENS.each_key do |token|
      key = token.delete("{}").to_sym
      next unless context[key]

      body.gsub!(token, context[key].to_s)
      subject_text.gsub!(token, context[key].to_s)
    end

    { subject: subject_text, body: body }
  end

  def self.find_or_default(event_type, organisation)
    template = ActsAsTenant.with_tenant(organisation) do
      active.find_by(event_type: event_type)
    end
    template || DefaultEmailTemplates.for(event_type)
  end
end
