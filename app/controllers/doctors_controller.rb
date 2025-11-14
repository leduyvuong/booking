# frozen_string_literal: true

class DoctorsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @doctors = Doctor.includes(:clinic).order(:name)
  end

  def show
    @doctor = Doctor.includes(:clinic, :time_slots).find(params[:id])
  end
end
