ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

if Rails.env.development? || Rails.env.test?
  require 'bootsnap/setup'
end