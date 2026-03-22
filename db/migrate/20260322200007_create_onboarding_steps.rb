class CreateOnboardingSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_steps do |t|
      t.references :onboarding_checklist, null: false, foreign_key: true
      t.string :step_type, null: false  # video, document, quiz, upload, sign, induction
      t.string :title, null: false
      t.text :description
      t.string :content_url
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :onboarding_steps, [ :onboarding_checklist_id, :position ]
  end
end
