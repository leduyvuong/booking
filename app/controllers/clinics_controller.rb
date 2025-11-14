# frozen_string_literal: true

class ClinicsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @clinics = Clinic.includes(:doctors).order(:name)
  end

  def show
    @clinic = Clinic.includes(doctors: :time_slots).find(params[:id])
  end
end
