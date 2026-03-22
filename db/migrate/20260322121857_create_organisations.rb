class CreateOrganisations < ActiveRecord::Migration[8.1]
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :slug
      t.string :primary_colour
      t.string :timezone
      t.string :locale
      t.string :email_sender_name
      t.string :email_sender_address

      t.timestamps
    end
    add_index :organisations, :slug, unique: true
  end
end
