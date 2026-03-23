class CreateSwapRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :swap_requests do |t|
      t.references :from_assignment, null: false, foreign_key: { to_table: :shift_assignments }
      t.references :to_assignment, null: true, foreign_key: { to_table: :shift_assignments }
      t.references :requested_by, null: false, foreign_key: { to_table: :users }
      t.references :reviewed_by, null: true, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false   # 0=pending, 1=approved, 2=declined
      t.text :notes
      t.datetime :reviewed_at

      t.timestamps
    end
  end
end
