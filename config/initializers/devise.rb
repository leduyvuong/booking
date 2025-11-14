# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = "no-reply@clinic-booking.test"

  require "devise/orm/active_record"

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 12

  config.reconfirmable = false

  config.password_length = 8..128
  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  config.warden do |manager|
    manager.failure_app = Devise::FailureApp
  end

  config.secret_key = ENV["DEVISE_SECRET_KEY"] if ENV["DEVISE_SECRET_KEY"].present?
end
