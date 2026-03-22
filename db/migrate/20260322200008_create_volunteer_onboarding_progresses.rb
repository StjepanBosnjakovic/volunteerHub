class CreateVolunteerOnboardingProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteer_onboarding_progresses do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.references :onboarding_step, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end

    add_index :volunteer_onboarding_progresses, [ :volunteer_profile_id, :onboarding_step_id ],
              unique: true, name: "index_vop_on_profile_and_step"
  end
end
