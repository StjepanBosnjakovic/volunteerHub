class CreateVolunteerApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteer_applications do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.references :opportunity, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.integer :position
      t.text :notes

      t.timestamps
    end

    add_index :volunteer_applications, [ :volunteer_profile_id, :opportunity_id ], unique: true, name: "index_volunteer_applications_unique"
    add_index :volunteer_applications, :status
  end
end
