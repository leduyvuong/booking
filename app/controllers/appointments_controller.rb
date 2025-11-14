# frozen_string_literal: true

class AppointmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new confirm create show]
  before_action :set_booking_form_defaults, only: :new

  def new
    @time_slot = @booking_form.time_slot
    unless @time_slot
      redirect_to doctors_path, alert: "Select a doctor and time slot to start your booking."
      return
    end

    return if @time_slot.bookable?

    redirect_to doctor_path(@time_slot.doctor), alert: "That time slot was just booked. Please choose another time."
  end

  def confirm
    @booking_form = BookingForm.new(booking_form_params)
    if @booking_form.valid?
      @time_slot = @booking_form.time_slot
      render :confirm
    else
      @time_slot = @booking_form.time_slot || load_time_slot(booking_form_params[:time_slot_id])
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @booking_form = BookingForm.new(booking_form_params)

    if @booking_form.valid?
      @appointment = BookingService.new(form: @booking_form, patient: current_user).book!
      track_recent_booking(@appointment)
      redirect_to appointment_path(@appointment), notice: "Appointment booked successfully."
    else
      @time_slot = @booking_form.time_slot || load_time_slot(booking_form_params[:time_slot_id])
      render :new, status: :unprocessable_entity
    end
  rescue BookingService::BookingError => e
    @time_slot = @booking_form.time_slot
    flash.now[:alert] = e.message
    render :confirm, status: :unprocessable_entity
  end

  def show
    @appointment = Appointment.includes(time_slot: { doctor: :clinic }).find(params[:id])
    authorize_show!
  end

  def cancel
    authenticate_user!
    @appointment = current_user.appointments.includes(time_slot: :doctor).find(params[:id])

    if @appointment.cancelled?
      redirect_to my_appointments_path, alert: "This appointment has already been cancelled."
      return
    end

    if @appointment.update(status: :cancelled, cancellation_reason: cancellation_reason_param.presence || "Cancelled by patient")
      redirect_to my_appointments_path(filter: params[:filter]), notice: "Appointment cancelled."
    else
      redirect_to my_appointments_path(filter: params[:filter]), alert: @appointment.errors.full_messages.to_sentence
    end
  end

  private

  def set_booking_form_defaults
    @booking_form = BookingForm.new(default_booking_params.merge(time_slot_id: params[:time_slot_id]))
  end

  def default_booking_params
    return {} unless current_user

    {
      patient_name: current_user.try(:full_name),
      patient_email: current_user.email,
      patient_phone: current_user.try(:phone)
    }.compact
  end

  def booking_form_params
    params.require(:booking_form).permit(:time_slot_id, :patient_name, :patient_phone, :patient_email, :notes, :terms_accepted)
  end

  def load_time_slot(id)
    return if id.blank?

    TimeSlot.includes(:doctor, doctor: :clinic).find_by(id: id)
  end

  def track_recent_booking(appointment)
    session[:recent_booking_ids] ||= []
    session[:recent_booking_ids] << appointment.id
    session[:recent_booking_ids] = session[:recent_booking_ids].last(5)
  end

  def authorize_show!
    return if current_user&.admin_role?
    return if current_user && @appointment.patient_id.present? && @appointment.patient_id == current_user.id
    return if session[:recent_booking_ids]&.include?(@appointment.id)

    redirect_to root_path, alert: "You do not have access to that appointment."
  end

  def cancellation_reason_param
    params.dig(:appointment, :cancellation_reason)
  end
end
