# Provides fallback email template content when no org-specific template exists.
module DefaultEmailTemplates
  TEMPLATES = {
    "welcome" => {
      subject: "Welcome to {{org_name}}!",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>Welcome to <strong>{{org_name}}</strong>! We're thrilled to have you on board.</p>
        <p>Head to your <a href="{{dashboard_link}}">dashboard</a> to get started.</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "application_approved" => {
      subject: "Your application has been approved — {{org_name}}",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>Great news! Your volunteer application has been <strong>approved</strong>.</p>
        <p>Visit your <a href="{{dashboard_link}}">dashboard</a> to complete your onboarding.</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "application_declined" => {
      subject: "Your application — {{org_name}}",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>Thank you for your interest in volunteering with <strong>{{org_name}}</strong>.</p>
        <p>Unfortunately, we are unable to accept your application at this time.</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "shift_reminder" => {
      subject: "Reminder: {{shift_title}} on {{shift_date}}",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>This is a reminder that you have a shift coming up:</p>
        <p><strong>{{shift_title}}</strong> — {{shift_date}}</p>
        <p>See you there!</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "hour_approved" => {
      subject: "Your hours have been approved — {{org_name}}",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>Your <strong>{{hours}} hours</strong> for {{program_name}} have been approved.</p>
        <p>View your <a href="{{dashboard_link}}">hour log</a> for details.</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "hour_rejected" => {
      subject: "Hours submission update — {{org_name}}",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>Your hours submission for {{program_name}} requires attention.</p>
        <p>Please visit your <a href="{{dashboard_link}}">dashboard</a> for details.</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "milestone_reached" => {
      subject: "Congratulations! You've reached {{milestone_label}} — {{org_name}}",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>Congratulations on reaching the <strong>{{milestone_label}}</strong> milestone!</p>
        <p>Your dedication makes a real difference. View your <a href="{{dashboard_link}}">achievements</a>.</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "credential_expiry" => {
      subject: "Action required: {{credential_name}} expires in {{days_until_expiry}} days",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>Your credential <strong>{{credential_name}}</strong> expires in {{days_until_expiry}} days.</p>
        <p>Please update it in your <a href="{{dashboard_link}}">profile</a>.</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "onboarding_reminder" => {
      subject: "Complete your onboarding — {{org_name}}",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>You have incomplete onboarding steps with <strong>{{org_name}}</strong>.</p>
        <p>Visit your <a href="{{dashboard_link}}">dashboard</a> to continue.</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    },
    "broadcast" => {
      subject: "Message from {{org_name}}",
      body_html: <<~HTML
        <p>Hi {{volunteer_name}},</p>
        <p>{{body}}</p>
        <p>Best,<br>The {{org_name}} Team</p>
      HTML
    }
  }.freeze

  def self.for(event_type)
    data = TEMPLATES[event_type.to_s] || TEMPLATES["broadcast"]
    OpenStruct.new(
      event_type: event_type,
      subject:    data[:subject],
      body_html:  data[:body_html],
      active:     true
    )
  end
end
