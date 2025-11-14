# frozen_string_literal: true

class TimeSlotsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_doctor

  def index
    @time_slots = @doctor.time_slots.available.ordered
  end

  private

  def set_doctor
    @doctor = Doctor.find(params[:doctor_id])
  end
end
