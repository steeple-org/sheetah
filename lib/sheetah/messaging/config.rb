# frozen_string_literal: true

module Sheetah
  module Messaging
    class Config
      def initialize(validate_messages: true)
        @validate_messages = validate_messages
      end

      attr_accessor :validate_messages
    end
  end
end
