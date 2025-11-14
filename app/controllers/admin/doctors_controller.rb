# frozen_string_literal: true

module Admin
  class DoctorsController < BaseController
    before_action :set_doctor, only: %i[show edit update destroy]
    before_action :load_clinics, only: %i[new edit create update]

    def index
      @doctors = Doctor.includes(:clinic).order(:name)
    end

    def show; end

    def new
      @doctor = Doctor.new
    end

    def create
      @doctor = Doctor.new(doctor_params)

      if @doctor.save
        redirect_to admin_doctor_path(@doctor), notice: "Doctor created successfully."
      else
        flash.now[:alert] = @doctor.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @doctor.update(doctor_params)
        redirect_to admin_doctor_path(@doctor), notice: "Doctor updated successfully."
      else
        flash.now[:alert] = @doctor.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @doctor.destroy
      redirect_to admin_doctors_path, notice: "Doctor removed successfully."
    end

    private

    def set_doctor
      @doctor = Doctor.includes(:clinic, time_slots: :appointments).find(params[:id])
    end

    def doctor_params
      params.require(:doctor).permit(:clinic_id, :name, :specialty, :bio, :avatar_url)
    end

    def load_clinics
      @clinics = Clinic.order(:name)
    end
  end
end
