class ShiftRole < ApplicationRecord
  belongs_to :shift
  has_many :shift_assignments, dependent: :nullify

  validates :label, presence: true
  validates :spots, presence: true, numericality: { greater_than: 0 }

  def assigned_count
    shift_assignments.confirmed.count
  end

  def spots_remaining
    [spots - assigned_count, 0].max
  end
end
