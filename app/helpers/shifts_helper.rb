module ShiftsHelper
  # Names of confirmed volunteers. Uses preloaded assignments when present.
  def confirmed_roster(shift)
    shift.shift_assignments.select(&:confirmed?).map { |sa| sa.volunteer_profile.full_name }
  end

  def shift_time_range(shift)
    "#{shift.starts_at.strftime('%-l:%M %p')} – #{shift.ends_at.strftime('%-l:%M %p')}"
  end

  # Tone, label and percent for a shift. Shifts without capacity report their sign-up count.
  def shift_fill_status(shift)
    fill_status(confirmed_roster(shift).size, shift.capacity)
  end
end
