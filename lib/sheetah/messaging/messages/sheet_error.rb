# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class SheetError < Message
        CODE = "sheet_error"

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
