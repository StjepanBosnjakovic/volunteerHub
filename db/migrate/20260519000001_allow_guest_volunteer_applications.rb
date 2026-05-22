class AllowGuestVolunteerApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :volunteer_applications, :guest_name, :string
    add_column :volunteer_applications, :guest_email, :string
    change_column_null :volunteer_applications, :volunteer_profile_id, true
    add_index :volunteer_applications, [:guest_email, :opportunity_id],
              unique: true,
              where: "guest_email IS NOT NULL",
              name: "index_volunteer_applications_on_guest_email_and_opportunity"
  end
end
