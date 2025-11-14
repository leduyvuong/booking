# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @today_appointments_count = base_appointment_scope.where(time_slots: { date: Date.current }).count
      @week_appointments_count = base_appointment_scope.where(time_slots: { date: Date.current..Date.current.end_of_week }).count
      @pending_appointments_count = Appointment.pending.count

      @recent_appointments = Appointment.includes(:patient, time_slot: :doctor)
                                        .order(created_at: :desc)
                                        .limit(10)
      @upcoming_time_slots = TimeSlot.includes(:doctor)
                                     .where(date: Date.current..(Date.current + 7.days))
                                     .order(:date, :start_time)
                                     .limit(10)
    end

    private

    def base_appointment_scope
      Appointment.joins(:time_slot).where.not(status: :cancelled)
    end
  end
end
