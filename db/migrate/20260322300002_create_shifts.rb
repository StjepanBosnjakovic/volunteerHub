class CreateShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :shifts do |t|
      t.references :program, null: false, foreign_key: true
      t.references :coordinator, null: true, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :location
      t.decimal :lat, precision: 10, scale: 7
      t.decimal :lng, precision: 10, scale: 7
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :capacity
      t.boolean :waitlist_enabled, default: false, null: false
      t.text :notes
      t.string :recurrence_rule
      t.string :qr_token
      t.integer :cancellation_cutoff_hours, default: 24

      t.timestamps
    end

    add_index :shifts, :qr_token, unique: true
    add_index :shifts, :starts_at
  end
end
