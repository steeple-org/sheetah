# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class DuplicatedHeader < Message
        CODE = "duplicated_header"

        validate_with do
          col

          def validate_code_data(message)
            case message.code_data
            in { value: String }
              true
            else
              false
            end
          end
        end
      end
    end
  end
end
