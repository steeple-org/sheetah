# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeArray < Message
        CODE = "must_be_array"

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
