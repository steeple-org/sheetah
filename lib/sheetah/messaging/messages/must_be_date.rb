# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeDate < Message
        CODE = "must_be_date"

        validate_with do
          cell

          def validate_code_data(message)
            case message.code_data
            in { format: String }
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
