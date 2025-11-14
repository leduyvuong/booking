# frozen_string_literal: true

module Admin
  class CalendarsController < BaseController
    def show
      @time_slots = TimeSlot.includes(:doctor, appointments: :patient).order(:date, :start_time)
      @events = build_events(@time_slots)
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
            doctorName: slot.doctor.name,
            bookedCount: slot.booked_count,
            maxPatients: slot.max_patients,
            status: slot.status,
            appointments: slot.appointments.order(:created_at).map do |appointment|
              {
                booking_number: appointment.booking_number,
                patient_name: appointment.patient_name,
                status: appointment.status,
                notes: appointment.notes
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

      Time.zone.local(date.year, date.month, date.day, time.hour, time.min)
    end
  end
end
