require "rails_helper"

RSpec.describe SurveyResponse, type: :model do
  let(:organisation)     { create(:organisation) }
  let(:survey)           { create(:survey, organisation: organisation) }
  let(:volunteer_profile) { create(:volunteer_profile, organisation: organisation) }

  describe "associations" do
    subject { build(:survey_response, survey: survey, volunteer_profile: volunteer_profile) }
    it { is_expected.to belong_to(:survey) }
    it { is_expected.to belong_to(:volunteer_profile) }
    it { is_expected.to belong_to(:shift).optional }
  end

  describe "validations" do
    subject { build(:survey_response, survey: survey, volunteer_profile: volunteer_profile) }
    it { is_expected.to validate_presence_of(:survey) }
    it { is_expected.to validate_presence_of(:volunteer_profile) }

    it "prevents duplicate response from same volunteer for same survey" do
      create(:survey_response, survey: survey, volunteer_profile: volunteer_profile)
      duplicate = build(:survey_response, survey: survey, volunteer_profile: volunteer_profile)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:survey_id]).to be_present
    end
  end

  describe "NPS extraction" do
    it "extracts NPS score from answers before save" do
      ActsAsTenant.with_tenant(organisation) do
        response = build(:survey_response,
                         survey:            survey,
                         volunteer_profile: volunteer_profile,
                         answers:           { "0" => "9", "1" => "Loved it!" })
        response.save!
        expect(response.nps_score).to eq(9)
      end
    end
  end
end
