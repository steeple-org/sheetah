# frozen_string_literal: true

require_relative "processor_result"
require_relative "utils/monadic_result"

module Sheetah
  class RowProcessor
    include Utils::MonadicResult

    def initialize(headers:, messenger:)
      @headers = headers
      @messenger = messenger
    end

    def call(row)
      messenger = @messenger.dup

      result = Success(@headers.zip(row.value))

      ProcessorResult.new(result: result, messages: messenger.messages)
    end
  end
end
