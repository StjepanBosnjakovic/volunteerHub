require "csv"

# Processes a coordinator-uploaded CSV and creates HourLog rows (source: bulk).
# Expected CSV columns:
#   volunteer_email, program_name, shift_id (optional), date (YYYY-MM-DD), hours, description
class HourBulkImportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 1

  def perform(csv_content, organisation_id, uploaded_by_id)
    organisation = Organisation.find(organisation_id)
    uploader     = User.find(uploaded_by_id)

    successes = 0
    errors    = []

    ActsAsTenant.with_tenant(organisation) do
      CSV.parse(csv_content, headers: true, header_converters: :symbol).each_with_index do |row, idx|
        line = idx + 2  # account for header row

        user    = User.find_by(email: row[:volunteer_email]&.strip, organisation: organisation)
        profile = user&.volunteer_profile
        program = Program.find_by(name: row[:program_name]&.strip)
        shift   = row[:shift_id].present? ? Shift.find_by(id: row[:shift_id].strip) : nil
        date    = Date.parse(row[:date].strip) rescue nil
        hours   = row[:hours].to_f

        if profile.nil?
          errors << "Row #{line}: volunteer '#{row[:volunteer_email]}' not found"
          next
        end

        if program.nil?
          errors << "Row #{line}: program '#{row[:program_name]}' not found"
          next
        end

        if date.nil?
          errors << "Row #{line}: invalid date '#{row[:date]}'"
          next
        end

        if hours <= 0 || hours > 24
          errors << "Row #{line}: hours must be between 0 and 24 (got #{hours})"
          next
        end

        HourLog.create!(
          volunteer_profile: profile,
          organisation:      organisation,
          program:           program,
          shift:             shift,
          date:              date,
          hours:             hours,
          description:       row[:description]&.strip,
          source:            :bulk,
          status:            :pending
        )
        successes += 1
      rescue => e
        errors << "Row #{line}: #{e.message}"
      end
    end

    Rails.logger.info "[HourBulkImportJob] org=#{organisation_id} successes=#{successes} errors=#{errors.size}"
    # Phase 5 will deliver the result summary via email to the uploader
  end
end
