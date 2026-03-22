class CreateEmergencyContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :emergency_contacts do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.string :name
      t.string :relationship
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
