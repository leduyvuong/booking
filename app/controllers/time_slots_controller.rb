# frozen_string_literal: true

class TimeSlotsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_doctor

  def index
    @selected_date = parsed_date
    scope = @doctor.time_slots.available.ordered
    scope = scope.on_date(@selected_date) if @selected_date.present?
    @time_slots = scope

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          frame_dom_id,
          partial: "time_slots/list",
          locals: { doctor: @doctor, date: @selected_date, time_slots: @time_slots }
        )
      end
    end
  end

  private

  def set_doctor
    @doctor = Doctor.find(params[:doctor_id])
  end

  def parsed_date
    return Date.current if params[:date].blank?

    Date.parse(params[:date])
  rescue ArgumentError
    Date.current
  end

  def frame_dom_id
    ActionView::RecordIdentifier.dom_id(@doctor, [:time_slots, @selected_date || Date.current])
  end
end
