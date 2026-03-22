class ApplicationAnswer < ApplicationRecord
  belongs_to :volunteer_application
  belongs_to :application_question

  has_one_attached :file_upload

  validates :application_question, presence: true
end
