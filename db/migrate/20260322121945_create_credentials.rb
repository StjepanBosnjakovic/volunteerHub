class CreateCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :credentials do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.string :name
      t.string :credential_type
      t.date :expires_at
      t.text :notes

      t.timestamps
    end
  end
end
