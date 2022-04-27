# frozen_string_literal: true

require_relative "messaging"
require_relative "processor_result"
require_relative "row_processor"
require_relative "sheet"

module Sheetah
  class SheetProcessor
    def call(*args, backend:, **opts)
      messenger = Messaging::Messenger.new

      result =
        backend.open(*args, **opts) do |sheet|
          row_processor = build_row_processor(sheet, messenger)

          sheet.each_row do |row|
            yield row_processor.call(row)
          end
        end

      messenger.exception(result.failure) if result.failure?

      ProcessorResult.new(result: result.discard, messages: messenger.messages)
    end

    private

    def build_row_processor(sheet, messenger)
      headers = sheet.each_header.to_a

      RowProcessor.new(headers: headers, messenger: messenger)
    end
  end
end
