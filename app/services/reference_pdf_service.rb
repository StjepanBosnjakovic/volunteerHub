class ReferencePdfService
  def initialize(reference)
    @reference = reference
    @profile   = reference.volunteer_profile
    @snapshot  = reference.stats_snapshot.with_indifferent_access
  end

  def render
    Prawn::Document.new do |pdf|
      # Header
      pdf.text "Volunteer Reference Letter", size: 22, style: :bold
      pdf.text @profile.volunteer_profile&.organisation&.name.to_s, size: 14, color: "555555"
      pdf.move_down 20

      # Volunteer info
      pdf.text "Volunteer: #{@profile.full_name}", size: 14, style: :bold
      pdf.text "Reference issued: #{@reference.issued_at&.strftime('%d %B %Y')}"
      pdf.text "Reference ID: ##{@reference.id}"
      pdf.move_down 20

      pdf.text "Verified Service Record", size: 14, style: :bold
      pdf.move_down 8

      table_data = [
        ["Total Approved Hours", "#{@snapshot[:total_hours]} hrs"],
        ["Shifts Attended",      @snapshot[:shifts_attended].to_s],
        ["Badges Earned",        @snapshot[:badges_earned].to_s],
        ["Programs",             Array(@snapshot[:programs]).join(", ")]
      ]

      pdf.table(table_data, cell_style: { padding: [6, 10] },
                             column_widths: [200, 300]) do
        row(0).background_color = "f0f4ff"
        row(0).font_style       = :bold
        cells.borders           = [:bottom]
      end

      pdf.move_down 20
      if @reference.notes.present?
        pdf.text "Coordinator Notes", size: 12, style: :bold
        pdf.text @reference.notes, size: 11
        pdf.move_down 16
      end

      pdf.text "This reference was generated automatically from verified records in VolunteerOS.",
               size: 9, color: "888888"
      pdf.text "Issued by: #{@reference.coordinator.email} on #{@reference.issued_at&.strftime('%d %B %Y')}",
               size: 9, color: "888888"
    end.render
  end
end
