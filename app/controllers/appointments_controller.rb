# frozen_string_literal: true

class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[show update]
  before_action :authorize_patient!, only: %i[create]

  def index
    @appointments = if current_user.admin_role?
                      Appointment.includes(:patient, time_slot: :doctor).order(created_at: :desc)
                    else
                      current_user.appointments.includes(time_slot: :doctor).order(created_at: :desc)
                    end
  end

  def show; end

  def create
    attributes = appointment_params.except(:time_slot_id).to_h
    appointment = Appointment.book!(
      time_slot: TimeSlot.find(appointment_params[:time_slot_id]),
      patient: current_user,
      attributes: attributes
    )

    redirect_to appointment, notice: "Appointment booked successfully."
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: appointments_path, alert: e.record.errors.full_messages.to_sentence
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: appointments_path, alert: "Time slot not found."
  end

  def update
    authorize_admin!

    if @appointment.update(update_params)
      redirect_to @appointment, notice: "Appointment updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = if current_user.admin_role?
                     Appointment.find(params[:id])
                   else
                     current_user.appointments.find(params[:id])
                   end
  end

  def authorize_patient!
    redirect_to new_user_session_path, alert: "You must sign in as a patient to book." unless current_user&.patient_role?
  end

  def authorize_admin!
    redirect_to appointments_path, alert: "You are not authorized to update appointments." unless current_user.admin_role?
  end

  def appointment_params
    params.require(:appointment).permit(:time_slot_id, :patient_name, :patient_phone, :patient_email, :notes)
  end

  def update_params
    params.require(:appointment).permit(:status, :notes)
  end
end
