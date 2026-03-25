class CreateTestimonials < ActiveRecord::Migration[8.1]
  def change
    create_table :testimonials do |t|
      t.bigint  :volunteer_profile_id, null: false
      t.bigint  :organisation_id,      null: false
      t.text    :quote,                null: false
      t.boolean :published,            default: false, null: false
      t.boolean :consent_given,        default: false, null: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :testimonials, :volunteer_profile_id
    add_index :testimonials, :organisation_id
    add_index :testimonials, :published

    add_foreign_key :testimonials, :volunteer_profiles
    add_foreign_key :testimonials, :organisations
  end
end
