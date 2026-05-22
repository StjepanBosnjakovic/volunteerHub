class AddOnboardingToOpportunities < ActiveRecord::Migration[8.1]
  def change
    # Link onboarding checklists to a specific opportunity
    add_column :onboarding_checklists, :opportunity_id, :bigint
    add_index  :onboarding_checklists, :opportunity_id
    add_foreign_key :onboarding_checklists, :opportunities, column: :opportunity_id

    # Track per-application onboarding progress
    add_column :volunteer_applications, :onboarding_token, :string
    add_column :volunteer_applications, :onboarding_completed_at, :datetime
    add_index  :volunteer_applications, :onboarding_token, unique: true

    # Distinguish application-time questions from onboarding-time questions
    add_column :application_questions, :context, :integer, default: 0, null: false
  end
end
