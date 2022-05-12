# frozen_string_literal: true

module Sheetah
  class RowProcessorResult
    def initialize(row:, result:, messages: [])
      @row = row
      @result = result
      @messages = messages
    end

    attr_reader :row, :result, :messages

    def ==(other)
      other.is_a?(self.class) &&
        row == other.row &&
        result == other.result &&
        messages == other.messages
    end
  end
end
