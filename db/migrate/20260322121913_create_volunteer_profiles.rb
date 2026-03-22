class CreateVolunteerProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteer_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :preferred_name
      t.string :pronouns
      t.date :date_of_birth
      t.string :phone
      t.text :bio
      t.integer :status
      t.integer :max_hours_per_week
      t.integer :max_hours_per_month
      t.boolean :is_minor
      t.datetime :policy_accepted_at

      t.timestamps
    end
    add_index :volunteer_profiles, :status
  end
end
