class CoordinatorProgram < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: { scope: :programme_id }
end
