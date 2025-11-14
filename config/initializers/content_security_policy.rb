# frozen_string_literal: true
# Define an application-wide content security policy

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https
    policy.connect_src :self, :https
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
end
