class CreateOpportunitySkills < ActiveRecord::Migration[8.1]
  def change
    create_table :opportunity_skills do |t|
      t.references :opportunity, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true

      t.timestamps
    end

    add_index :opportunity_skills, [ :opportunity_id, :skill_id ], unique: true
  end
end
