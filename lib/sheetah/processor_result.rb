# frozen_string_literal: true

module Sheetah
  class ProcessorResult
    def initialize(result:, messages: [])
      @result = result
      @messages = messages
    end

    attr_reader :result, :messages

    def ==(other)
      other.is_a?(self.class) && result == other.result && messages == other.messages
    end
  end
end
