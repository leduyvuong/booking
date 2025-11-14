# frozen_string_literal: true

module Admin
  class TimeSlotsController < BaseController
    before_action :set_time_slot, only: %i[show edit update destroy]
    before_action :load_doctors, only: %i[index new edit create update bulk_new bulk_preview bulk_create]

    def index
      @filter = filter_params

      @time_slots = TimeSlot.includes(:doctor).order(:date, :start_time)
      @time_slots = @time_slots.where(doctor_id: @filter[:doctor_id]) if @filter[:doctor_id].present?
      @time_slots = @time_slots.where(status: @filter[:status]) if @filter[:status].present?
      if @filter[:start_date].present?
        @time_slots = @time_slots.where("date >= ?", @filter[:start_date])
      end
      if @filter[:end_date].present?
        @time_slots = @time_slots.where("date <= ?", @filter[:end_date])
      end
    end

    def show; end

    def new
      @time_slot = TimeSlot.new
    end

    def create
      @time_slot = TimeSlot.new(time_slot_params)

      if @time_slot.save
        redirect_to admin_time_slot_path(@time_slot), notice: "Time slot created successfully."
      else
        flash.now[:alert] = @time_slot.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @time_slot.update(time_slot_params)
        redirect_to admin_time_slot_path(@time_slot), notice: "Time slot updated successfully."
      else
        flash.now[:alert] = @time_slot.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @time_slot.destroy
      redirect_to admin_time_slots_path, notice: "Time slot removed successfully."
    end

    def bulk_new
      @generator = TimeSlots::BulkGenerator.new(default_bulk_params)
      @generated_slots = []
    end

    def bulk_preview
      @generator = TimeSlots::BulkGenerator.new(bulk_params)
      @generated_slots = @generator.preview

      if @generator.errors.any?
        flash.now[:alert] = @generator.errors.full_messages.to_sentence
      else
        flash.now[:notice] = "Previewing #{@generated_slots.count} time slots (#{@generator.duplicates.count} duplicates skipped)."
      end

      render :bulk_new, status: @generator.errors.any? ? :unprocessable_entity : :ok
    end

    def bulk_create
      @generator = TimeSlots::BulkGenerator.new(bulk_params)

      if @generator.save
        redirect_to admin_time_slots_path, notice: "Created #{@generator.created_count} time slots successfully."
      else
        @generated_slots = @generator.preview
        flash.now[:alert] = @generator.errors.full_messages.to_sentence
        render :bulk_new, status: :unprocessable_entity
      end
    end

    private

    def set_time_slot
      @time_slot = TimeSlot.includes(doctor: :clinic, appointments: :patient).find(params[:id])
    end

    def time_slot_params
      params.require(:time_slot).permit(:doctor_id, :date, :start_time, :end_time, :max_patients, :status)
    end

    def bulk_params
      params.require(:bulk).permit(:doctor_id, :start_date, :end_date, :start_time, :end_time, :duration_minutes, :max_patients, :status)
    end

    def default_bulk_params
      {
        start_date: Date.current,
        end_date: Date.current + 6.days,
        start_time: "09:00",
        end_time: "17:00",
        duration_minutes: 30,
        max_patients: 5,
        status: "available"
      }
    end

    def filter_params
      params.fetch(:filter, ActionController::Parameters.new).permit(:doctor_id, :status, :start_date, :end_date)
    end

    def load_doctors
      @doctors = Doctor.order(:name)
    end
  end
end
