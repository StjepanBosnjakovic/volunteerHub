require "rails_helper"

RSpec.describe Survey, type: :model do
  let(:organisation) { create(:organisation) }

  describe "associations" do
    subject { build(:survey, organisation: organisation) }
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to have_many(:survey_responses).dependent(:destroy) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:trigger)
        .with_values(post_shift: 0, post_program: 1, pulse: 2, manual: 3)
    }
  end

  describe "validations" do
    subject { build(:survey, organisation: organisation) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:trigger) }
  end

  describe "#question_list" do
    it "returns an array of question hashes" do
      survey = build(:survey, organisation: organisation)
      expect(survey.question_list).to be_an(Array)
      expect(survey.question_list.first).to include("type", "label")
    end
  end

  describe "#nps_question?" do
    it "returns true when survey has an NPS question" do
      survey = build(:survey, organisation: organisation)
      expect(survey.nps_question?).to be true
    end

    it "returns false when survey has no NPS question" do
      survey = build(:survey, organisation: organisation,
                     questions: [{ "type" => "text", "label" => "Feedback?" }])
      expect(survey.nps_question?).to be false
    end
  end

  describe "#net_promoter_score" do
    it "calculates NPS correctly" do
      ActsAsTenant.with_tenant(organisation) do
        survey = create(:survey, organisation: organisation)
        profile1 = create(:volunteer_profile, organisation: organisation)
        profile2 = create(:volunteer_profile, organisation: organisation)
        profile3 = create(:volunteer_profile, organisation: organisation)

        # 1 promoter (9-10), 1 passive (7-8), 1 detractor (0-6)
        create(:survey_response, survey: survey, volunteer_profile: profile1, nps_score: 10, answers: { "0" => "10" })
        create(:survey_response, survey: survey, volunteer_profile: profile2, nps_score: 7, answers: { "0" => "7" })
        create(:survey_response, survey: survey, volunteer_profile: profile3, nps_score: 4, answers: { "0" => "4" })

        # NPS = (1/3 - 1/3) * 100 = 0
        expect(survey.net_promoter_score).to eq(0)
      end
    end
  end
end
