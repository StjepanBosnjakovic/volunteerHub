class CreateMilestones < ActiveRecord::Migration[8.1]
  def change
    create_table :milestones do |t|
      t.references :organisation, null: false, foreign_key: true
      t.decimal :threshold_hours, precision: 8, scale: 2, null: false
      t.string :label, null: false
      t.text :message
      t.timestamps
    end

    add_index :milestones, [:organisation_id, :threshold_hours], unique: true

    # Track which volunteers have reached which milestones
    create_table :volunteer_milestones do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.references :milestone, null: false, foreign_key: true
      t.datetime :reached_at, null: false
      t.timestamps
    end

    add_index :volunteer_milestones, [:volunteer_profile_id, :milestone_id], unique: true,
      name: "index_volunteer_milestones_unique"
  end
end
