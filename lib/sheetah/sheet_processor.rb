# frozen_string_literal: true

require_relative "row_processor"
require_relative "sheet"

module Sheetah
  class SheetProcessor
    def call(*args, backend:, **opts)
      result =
        backend.open(*args, **opts) do |sheet|
          row_processor = build_row_processor(sheet)

          sheet.each_row do |row|
            yield row_processor.call(row)
          end
        end

      result.discard
    end

    private

    def build_row_processor(sheet)
      headers = sheet.each_header.to_a

      RowProcessor.new(headers: headers)
    end
  end
end
