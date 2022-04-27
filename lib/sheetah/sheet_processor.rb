# frozen_string_literal: true

require_relative "headers"
require_relative "messaging"
require_relative "processor_result"
require_relative "row_processor"
require_relative "sheet"
require_relative "utils/monadic_result"

module Sheetah
  class SheetProcessor
    include Utils::MonadicResult

    def initialize(specification)
      @specification = specification
    end

    def call(*args, backend:, **opts)
      messenger = Messaging::Messenger.new

      result = Do() do
        backend.open(*args, **opts) do |sheet|
          row_processor = build_row_processor(sheet, messenger)

          sheet.each_row do |row|
            yield row_processor.call(row)
          end
        end
      end

      handle_result(result, messenger)
    end

    private

    def parse_headers(sheet, messenger)
      headers = Headers.new(specification: @specification, messenger: messenger)

      sheet.each_header do |header|
        headers.add(header)
      end

      headers.result
    end

    def build_row_processor(sheet, messenger)
      headers = parse_headers(sheet, messenger).unwrap

      RowProcessor.new(headers: headers, messenger: messenger)
    end

    def handle_result(result, messenger)
      result.or do |failure|
        messenger.error(failure.msg_code) if failure.respond_to?(:msg_code)
      end

      ProcessorResult.new(result: result.discard, messages: messenger.messages)
    end
  end
end
