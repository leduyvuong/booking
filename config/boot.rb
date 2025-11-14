# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV.fetch("BUNDLE_GEMFILE"))
require "bootsnap/setup"
