class BroadcastMailer < ApplicationMailer
  def send_broadcast(user, subject, body_html, organisation)
    @user         = user
    @body_html    = body_html
    @organisation = organisation

    mail(
      to:      @user.email,
      subject: subject,
      from:    sender_address(@organisation)
    )
  end

  private

  def sender_address(org)
    if org.email_sender_address.present?
      "#{org.email_sender_name} <#{org.email_sender_address}>"
    else
      default_from
    end
  end
end
