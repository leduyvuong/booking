# frozen_string_literal: true

module Admin
  class CalendarsController < BaseController
    def show
      @time_slots = TimeSlot.includes(:doctor, appointments: :patient).order(:date, :start_time)
      @events = build_events(@time_slots)
      
      # Debug: log the events to see if there are any JSON serialization issues
      Rails.logger.debug "Events JSON: #{@events.to_json}"
    rescue => e
      Rails.logger.error "Error in calendar show: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @events = []
    end

    private

    def build_events(time_slots)
      time_slots.map do |slot|
        start_at = combine_datetime(slot.date, slot.start_time)
        end_at = combine_datetime(slot.date, slot.end_time)
        next unless start_at && end_at

        {
          id: slot.id,
          title: event_title(slot),
          start: start_at.iso8601,
          end: end_at.iso8601,
          backgroundColor: event_color(slot),
          borderColor: event_color(slot),
          extendedProps: {
            doctorName: slot.doctor.name&.strip,
            bookedCount: slot.booked_count,
            maxPatients: slot.max_patients,
            status: slot.status,
            appointments: slot.appointments.order(:created_at).map do |appointment|
              {
                booking_number: appointment.booking_number&.strip,
                patient_name: appointment.patient_name&.strip,
                status: appointment.status,
                notes: appointment.notes&.strip
              }
            end
          }
        }
      end.compact
    end

    def event_title(slot)
      "#{slot.doctor.name} (#{slot.booked_count}/#{slot.max_patients} booked)"
    end

    def event_color(slot)
      return "#9CA3AF" if slot.blocked?
      return "#EF4444" if slot.booked_count >= slot.max_patients
      return "#22C55E" if slot.booked_count.zero?

      "#F97316"
    end

    def combine_datetime(date, time)
      return if date.blank? || time.blank?

      # Handle time column type - it comes as a string in "HH:MM:SS" format
      if time.is_a?(String)
        time_parts = time.split(':')
        hour = time_parts[0].to_i
        minute = time_parts[1].to_i
      else
        # If it's already a Time object, extract hour and minute
        hour = time.hour
        minute = time.min
      end
      
      Time.zone.local(date.year, date.month, date.day, hour, minute)
    end
  end
end
