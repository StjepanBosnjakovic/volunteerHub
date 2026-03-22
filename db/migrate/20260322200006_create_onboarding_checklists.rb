class CreateOnboardingChecklists < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_checklists do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :target_role  # volunteer, coordinator, etc.
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
