# frozen_string_literal: true

require_relative "processor_result"
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
        @headers.zip(row.value) do |header, cell|
          messenger.scope_col!(cell.col) do
            builder.add(header.column, cell.value)
          end
        end
      end

      ProcessorResult.new(result: builder.result, messages: messenger.messages)
    end
  end
end
