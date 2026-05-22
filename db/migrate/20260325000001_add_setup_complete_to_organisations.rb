class AddSetupCompleteToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :setup_complete, :boolean, default: false, null: false
  end
end
