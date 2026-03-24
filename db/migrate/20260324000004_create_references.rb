class CreateReferences < ActiveRecord::Migration[8.1]
  def change
    create_table :references do |t|
      t.bigint  :volunteer_profile_id, null: false
      t.bigint  :coordinator_id,       null: false   # User (coordinator who writes it)
      t.jsonb   :stats_snapshot,       default: {}   # hours, shifts, badges at time of issue
      t.integer :status,               default: 0, null: false  # requested / issued / declined
      t.text    :notes
      t.datetime :issued_at

      t.timestamps
    end

    add_index :references, :volunteer_profile_id
    add_index :references, :coordinator_id
    add_index :references, :status

    add_foreign_key :references, :volunteer_profiles
    add_foreign_key :references, :users, column: :coordinator_id
  end
end
