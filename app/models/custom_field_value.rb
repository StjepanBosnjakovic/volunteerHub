class CustomFieldValue < ApplicationRecord
  belongs_to :custom_field
  belongs_to :customizable, polymorphic: true

  validates :custom_field, presence: true
end
