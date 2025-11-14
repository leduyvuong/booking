# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    @top_doctors = Doctor.includes(:clinic).order(created_at: :desc).limit(4)
  end
end
