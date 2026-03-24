# Sends a BroadcastMessage to all segment recipients.
# Also handles EmailCampaign sends when job_type == "campaign".
class BroadcastMessageJob < ApplicationJob
  queue_as :mailers

  def perform(resource_id, job_type = "broadcast")
    if job_type == "campaign"
      send_email_campaign(resource_id)
    else
      send_broadcast(resource_id)
    end
  end

  private

  def send_broadcast(broadcast_id)
    broadcast = BroadcastMessage.find_by(id: broadcast_id)
    return unless broadcast

    ActsAsTenant.with_tenant(broadcast.organisation) do
      recipients = broadcast.resolve_recipients
      count = 0

      recipients.find_each do |user|
        deliver_to_user(broadcast, user)
        count += 1
      end

      broadcast.update!(status: :sent, recipient_count: count, sent_at: Time.current)
    end
  end

  def send_email_campaign(campaign_id)
    campaign = EmailCampaign.find_by(id: campaign_id)
    return unless campaign

    ActsAsTenant.with_tenant(campaign.organisation) do
      recipients = build_segment(campaign)
      count = 0
      half  = (recipients.count / 2.0).ceil

      recipients.find_each.with_index do |user, idx|
        subject = (campaign.ab_test? && idx >= half) ? campaign.subject_b : campaign.subject_a
        BroadcastMailer.send_broadcast(user, subject, campaign.body_html, campaign.organisation).deliver_later
        count += 1
      end

      campaign.update!(status: :sent, recipient_count: count, sent_at: Time.current)
    end
  end

  def deliver_to_user(broadcast, user)
    case broadcast.channel.to_sym
    when :in_app
      Notification.create_for(
        recipient:  user,
        type:       "broadcast",
        data:       { subject: broadcast.subject, body: broadcast.body.truncate(200) },
        notifiable: broadcast
      )
    when :email
      BroadcastMailer.send_broadcast(user, broadcast.subject, broadcast.body, broadcast.organisation).deliver_later
    when :sms
      Rails.logger.info "[BroadcastMessageJob] SMS to #{user.id}: #{broadcast.subject}"
    when :whatsapp
      Rails.logger.info "[BroadcastMessageJob] WhatsApp to #{user.id}: #{broadcast.subject}"
    end
  end

  def build_segment(campaign)
    filters = campaign.segment_filters || {}
    scope = campaign.organisation.users.where(role: :volunteer)
    scope = scope.where(role: filters["role"]) if filters["role"].present?
    scope
  end
end
