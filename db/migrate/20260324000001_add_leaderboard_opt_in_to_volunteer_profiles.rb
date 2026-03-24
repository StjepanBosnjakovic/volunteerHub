class AddLeaderboardOptInToVolunteerProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :volunteer_profiles, :show_on_leaderboard, :boolean, default: false, null: false
  end
end
