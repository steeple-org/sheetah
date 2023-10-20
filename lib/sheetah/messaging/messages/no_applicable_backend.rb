# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class NoApplicableBackend < Message
        CODE = "no_applicable_backend"

        validate_with do
          sheet

          def validate_code_data(message)
            message.code_data.nil?
          end
        end
      end
    end
  end
end
