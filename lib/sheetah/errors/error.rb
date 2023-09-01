# frozen_string_literal: true

module Sheetah
  module Errors
    class Error < StandardError
      class << self
        def inherited(klass)
          super

          klass.msg_code! if klass.detect_msg_code?
        end

        attr_reader :msg_code

        def detect_msg_code?
          name && /^[a-z0-9:]+$/i.match?(name)
        end

        def msg_code!(msg_code = build_msg_code)
          @msg_code = msg_code
        end

        private

        def build_msg_code
          unless detect_msg_code?
            raise ::TypeError, "Cannot build msg_code from anonymous exception: #{inspect}"
          end

          msg_code = name.dup
          msg_code.gsub!("::", ".")
          msg_code.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          msg_code.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          msg_code.downcase!

          msg_code
        end
      end

      msg_code!

      def msg_code
        self.class.msg_code
      end
    end
  end
end
