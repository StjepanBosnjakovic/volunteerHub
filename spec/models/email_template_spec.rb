require "rails_helper"

RSpec.describe EmailTemplate, type: :model do
  let(:organisation) { create(:organisation) }

  describe "associations" do
    subject { build(:email_template, organisation: organisation) }
    it { is_expected.to belong_to(:organisation) }
  end

  describe "validations" do
    subject { build(:email_template, organisation: organisation) }
    it { is_expected.to validate_presence_of(:event_type) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:body_html) }

    it "validates event_type is in EVENT_TYPES" do
      template = build(:email_template, organisation: organisation, event_type: "invalid_type")
      expect(template).not_to be_valid
    end

    it "validates uniqueness of event_type scoped to organisation" do
      ActsAsTenant.with_tenant(organisation) do
        create(:email_template, organisation: organisation, event_type: "welcome")
        duplicate = build(:email_template, organisation: organisation, event_type: "welcome")
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe "#interpolate" do
    it "replaces tokens with context values" do
      template = build(:email_template,
        organisation: organisation,
        subject:   "Welcome {{volunteer_name}}",
        body_html: "<p>Hi {{volunteer_name}}, from {{org_name}}</p>"
      )
      result = template.interpolate(volunteer_name: "Jane", org_name: "Green NGO")
      expect(result[:subject]).to eq("Welcome Jane")
      expect(result[:body]).to include("Hi Jane, from Green NGO")
    end
  end

  describe "scopes" do
    it ".active returns only active templates" do
      ActsAsTenant.with_tenant(organisation) do
        active   = create(:email_template, organisation: organisation, event_type: "welcome",     active: true)
        inactive = create(:email_template, organisation: organisation, event_type: "broadcast",   active: false)
        expect(EmailTemplate.active).to include(active)
        expect(EmailTemplate.active).not_to include(inactive)
      end
    end
  end
end
