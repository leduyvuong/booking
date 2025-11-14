# frozen_string_literal: true

class DoctorsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @specialties = Doctor.distinct.order(:specialty).pluck(:specialty)
    @selected_specialty = params[:specialty].presence

    @doctors = Doctor.includes(:clinic)
    @doctors = @doctors.where(specialty: @selected_specialty) if @selected_specialty.present?
    @doctors = @doctors.order(:name)
  end

  def show
    @doctor = Doctor.includes(:clinic, :time_slots).find(params[:id])
    @selected_date = begin
      Date.parse(params[:date])
    rescue ArgumentError, TypeError
      @doctor.time_slots.available.order(:date).first&.date || Date.current
    end
  end
end
