class EmailTemplatesController < ApplicationController
  before_action :set_email_template, only: %i[show edit update destroy preview]

  def index
    authorize EmailTemplate
    @email_templates = policy_scope(EmailTemplate).ordered
    @available_event_types = EmailTemplate::EVENT_TYPES - @email_templates.pluck(:event_type)
  end

  def show
    authorize @email_template
  end

  def new
    authorize EmailTemplate
    @email_template = EmailTemplate.new
    @event_types = EmailTemplate::EVENT_TYPES
  end

  def create
    authorize EmailTemplate
    @email_template = EmailTemplate.new(email_template_params)
    @email_template.organisation = current_user.organisation

    if @email_template.save
      redirect_to email_templates_path, notice: "Email template created."
    else
      @event_types = EmailTemplate::EVENT_TYPES
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @email_template
    @event_types = EmailTemplate::EVENT_TYPES
  end

  def update
    authorize @email_template

    if @email_template.update(email_template_params)
      redirect_to email_templates_path, notice: "Email template updated."
    else
      @event_types = EmailTemplate::EVENT_TYPES
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @email_template
    @email_template.destroy
    redirect_to email_templates_path, notice: "Email template deleted."
  end

  def preview
    authorize @email_template
    sample_context = {
      volunteer_name:    "Jane Volunteer",
      org_name:          current_user.organisation.name,
      shift_title:       "Community Garden",
      shift_date:        Time.current.strftime("%A, %d %b at %H:%M"),
      program_name:      "Green Spaces",
      hours:             "4.5",
      milestone_label:   "50 Hours Champion",
      credential_name:   "First Aid Certificate",
      days_until_expiry: "14",
      dashboard_link:    dashboard_url,
      unsubscribe_link:  "#"
    }

    @preview = @email_template.interpolate(sample_context)

    render layout: false
  end

  private

  def set_email_template
    @email_template = policy_scope(EmailTemplate).find(params[:id])
  end

  def email_template_params
    params.require(:email_template).permit(:event_type, :subject, :body_html, :active)
  end
end
