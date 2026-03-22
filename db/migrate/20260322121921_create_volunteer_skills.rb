class CreateVolunteerSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteer_skills do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true

      t.timestamps
    end
  end
end
