class AddPhase4Settings < ActiveRecord::Migration[8.1]
  def change
    add_column :organisations, :auto_approve_hours, :boolean, null: false, default: false
  end
end
