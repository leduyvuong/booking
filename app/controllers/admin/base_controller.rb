# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    helper Admin::NavigationHelper
    helper Admin::StatusHelper

    before_action :authorize_admin!

    private

    def authorize_admin!
      return if current_user&.admin_role?

      redirect_to root_path, alert: "You are not authorized to access the admin area."
    end
  end
end
