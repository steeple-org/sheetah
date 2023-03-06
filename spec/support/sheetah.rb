# frozen_string_literal: true

require "sheetah/messaging"

Sheetah::Messaging.configure do |config|
  config.validate_messages = true
end
