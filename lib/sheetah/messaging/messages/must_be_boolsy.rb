# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeBoolsy < Message
        CODE = "must_be_boolsy"

        validate_with do
          cell

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
