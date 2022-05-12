# frozen_string_literal: true

require_relative "row_processor_result"
require_relative "row_value_builder"

module Sheetah
  class RowProcessor
    def initialize(headers:, messenger:)
      @headers = headers
      @messenger = messenger
    end

    def call(row)
      messenger = @messenger.dup

      builder = RowValueBuilder.new(messenger)

      messenger.scope_row!(row.row) do
        @headers.each do |header|
          cell = row.value[header.row_value_index]

          messenger.scope_col!(cell.col) do
            builder.add(header.column, cell.value)
          end
        end
      end

      build_result(row, builder, messenger)
    end

    private

    def build_result(row, builder, messenger)
      RowProcessorResult.new(
        row: row.row,
        result: builder.result,
        messages: messenger.messages
      )
    end
  end
end
