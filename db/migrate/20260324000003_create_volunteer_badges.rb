class CreateVolunteerBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteer_badges do |t|
      t.bigint   :volunteer_profile_id, null: false
      t.bigint   :badge_id,             null: false
      t.bigint   :awarded_by_id                       # User who manually awarded (nil = auto)
      t.datetime :awarded_at,           null: false

      t.timestamps
    end

    add_index :volunteer_badges, [:volunteer_profile_id, :badge_id], unique: true, name: "index_volunteer_badges_unique"
    add_index :volunteer_badges, :badge_id
    add_index :volunteer_badges, :awarded_by_id

    add_foreign_key :volunteer_badges, :volunteer_profiles
    add_foreign_key :volunteer_badges, :badges
    add_foreign_key :volunteer_badges, :users, column: :awarded_by_id
  end
end
