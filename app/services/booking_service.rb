# frozen_string_literal: true

class BookingService
  class BookingError < StandardError; end

  def initialize(form:, patient: nil)
    @form = form
    @patient = patient
  end

  def book!
    raise BookingError, "Time slot is required" unless form.time_slot

    appointment = Appointment.book!(
      time_slot: form.time_slot,
      patient: patient,
      attributes: form.to_appointment_attributes
    )

    appointment.confirmed!
    appointment
  rescue ActiveRecord::RecordInvalid => e
    raise BookingError, e.record.errors.full_messages.to_sentence
  end

  private

  attr_reader :form, :patient
end
