# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class CleanedString < Message
        CODE = "cleaned_string"

        validate_with do
          cell

          def validate_code_data(message)
            message.code_data.nil?
          end
        end
      end
    end
  end
end
