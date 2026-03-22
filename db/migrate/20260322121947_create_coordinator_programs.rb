class CreateCoordinatorPrograms < ActiveRecord::Migration[8.1]
  def change
    create_table :coordinator_programs do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :programme_id

      t.timestamps
    end
  end
end
