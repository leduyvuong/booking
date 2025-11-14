# frozen_string_literal: true

module Patient
  class AppointmentsController < ApplicationController
    before_action :authenticate_user!

    def index
      @filter = allowed_filters.include?(params[:filter]) ? params[:filter] : "upcoming"
      @appointments = scoped_appointments
    end

    private

    def scoped_appointments
      base = current_user.appointments.includes(time_slot: { doctor: :clinic }).order("time_slots.date ASC, time_slots.start_time ASC")

      case @filter
      when "past"
        base.joins(:time_slot).where("time_slots.date < ? OR (time_slots.date = ? AND time_slots.end_time < ?)", Date.current, Date.current, Time.zone.now.strftime("%H:%M:%S")).where.not(status: :cancelled)
      when "cancelled"
        base.where(status: :cancelled)
      else
        base.joins(:time_slot).where("time_slots.date > ? OR (time_slots.date = ? AND time_slots.end_time >= ?)", Date.current, Date.current, Time.zone.now.strftime("%H:%M:%S")).where.not(status: :cancelled)
      end
    end

    def allowed_filters
      %w[upcoming past cancelled]
    end
  end
end
