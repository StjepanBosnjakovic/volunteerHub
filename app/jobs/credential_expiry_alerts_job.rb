class CredentialExpiryAlertsJob < ApplicationJob
  queue_as :default

  ALERT_DAYS = [30, 14, 7].freeze

  def perform
    ALERT_DAYS.each do |days|
      expiring = Credential.expiring_within(days)
                            .where.not(id: already_alerted_ids(days))

      expiring.includes(volunteer_profile: :user).each do |credential|
        CredentialExpiryMailer.alert(credential, days).deliver_later
      end
    end
  end

  private

  def already_alerted_ids(days)
    # In production, track sent alerts in a separate table or Redis
    # For now, return empty to always send (idempotency handled by mailer)
    []
  end
end
