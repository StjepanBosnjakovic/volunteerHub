class CreateOpportunities < ActiveRecord::Migration[8.1]
  def change
    create_table :opportunities do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :location
      t.decimal :lat, precision: 10, scale: 7
      t.decimal :lng, precision: 10, scale: 7
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :spots_available
      t.string :commitment_level
      t.integer :status, default: 0, null: false
      t.string :slug, null: false
      t.string :category

      t.timestamps
    end

    add_index :opportunities, :slug, unique: true
    add_index :opportunities, :status
    add_index :opportunities, :starts_at
    add_index :opportunities, [ :organisation_id, :status ]
  end
end
