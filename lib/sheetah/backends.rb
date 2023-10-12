# frozen_string_literal: true

require_relative "utils/monadic_result"

module Sheetah
  module Backends
    SimpleError = Struct.new(:msg_code)
    private_constant :SimpleError

    class << self
      def open(*args, **opts, &block)
        backend = opts.delete(:backend)

        if backend.nil?
          return Utils::MonadicResult::Failure.new(SimpleError.new("no_applicable_backend"))
        end

        backend.open(*args, **opts, &block)
      end
    end
  end
end
