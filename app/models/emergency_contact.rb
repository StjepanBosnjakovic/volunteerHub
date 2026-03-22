class EmergencyContact < ApplicationRecord
  belongs_to :volunteer_profile

  validates :name, presence: true
  validates :phone, presence: true
  validates :relationship, presence: true
end
