# frozen_string_literal: true

module Admin
  class AppointmentsController < BaseController
    before_action :set_appointment, only: %i[show update cancel]
    before_action :load_filters, only: %i[index]

    def index
      respond_to do |format|
        format.html do
          scope = filtered_scope.includes(:patient, time_slot: :doctor).order(created_at: :desc)
          @current_page = [params[:page].to_i, 1].max
          @per_page = 20
          @total_count = scope.count
          @total_pages = (@total_count / @per_page.to_f).ceil
          @appointments = scope.limit(@per_page).offset((@current_page - 1) * @per_page)
        end
        format.csv do
          send_data generate_csv(filtered_scope.order(created_at: :desc)),
                    filename: "appointments-#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}.csv"
        end
      end
    end

    def show
      @time_slot = @appointment.time_slot
    end

    def update
      if appointment_update_params[:status] == "cancelled"
        redirect_to admin_appointment_path(@appointment), alert: "Use the cancel action to cancel appointments."
        return
      end

      if @appointment.update(appointment_update_params)
        redirect_to admin_appointment_path(@appointment), notice: "Appointment updated successfully."
      else
        redirect_to admin_appointment_path(@appointment), alert: @appointment.errors.full_messages.to_sentence
      end
    end

    def cancel
      reason = params.dig(:appointment, :cancellation_reason)

      if reason.blank?
        redirect_to admin_appointment_path(@appointment), alert: "Cancellation reason is required."
        return
      end

      if @appointment.update(status: :cancelled, cancellation_reason: reason)
        redirect_to admin_appointment_path(@appointment), notice: "Appointment cancelled successfully."
      else
        redirect_to admin_appointment_path(@appointment), alert: @appointment.errors.full_messages.to_sentence
      end
    end

    def bulk_update
      ids = Array(params[:appointment_ids])
      if ids.blank?
        redirect_to admin_appointments_path, alert: "Select at least one appointment to perform a bulk action."
        return
      end

      case params[:bulk_action]
      when "confirm"
        confirmed = 0
        Appointment.transaction do
          Appointment.where(id: ids).find_each do |appointment|
            next if appointment.cancelled?

            confirmed += 1 if appointment.update(status: :confirmed)
          end
        end
        redirect_to admin_appointments_path, notice: "Confirmed #{confirmed} appointments."
      else
        redirect_to admin_appointments_path, alert: "Unsupported bulk action."
      end
    end

    private

    def set_appointment
      @appointment = Appointment.includes(:patient, time_slot: :doctor).find(params[:id])
    end

    def load_filters
      @filter = filter_params
      @doctors = Doctor.order(:name)
      @statuses = Appointment.statuses.keys
    end

    def filter_params
      params.fetch(:filter, ActionController::Parameters.new).permit(:doctor_id, :status, :start_date, :end_date)
    end

    def filtered_scope
      scope = Appointment.includes(time_slot: :doctor)
      scope = scope.where(status: @filter[:status]) if @filter[:status].present?
      if @filter[:doctor_id].present?
        scope = scope.joins(:time_slot).where(time_slots: { doctor_id: @filter[:doctor_id] })
      end
      if @filter[:start_date].present?
        scope = scope.joins(:time_slot).where("time_slots.date >= ?", @filter[:start_date])
      end
      if @filter[:end_date].present?
        scope = scope.joins(:time_slot).where("time_slots.date <= ?", @filter[:end_date])
      end
      scope
    end

    def appointment_update_params
      params.require(:appointment).permit(:status)
    end

    def generate_csv(scope)
      CSV.generate(headers: true) do |csv|
        csv << ["Booking #", "Patient", "Doctor", "Date", "Time", "Status"]
        scope.includes(:patient, time_slot: :doctor).find_each do |appointment|
          slot = appointment.time_slot
          csv << [
            appointment.booking_number,
            appointment.patient_name,
            slot.doctor.name,
            slot.date,
            "#{slot.start_time.strftime('%H:%M')} - #{slot.end_time.strftime('%H:%M')}",
            appointment.status
          ]
        end
      end
    end
  end
end
