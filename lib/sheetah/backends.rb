# frozen_string_literal: true

require_relative "backends_registry"
require_relative "utils/monadic_result"

module Sheetah
  module Backends
    @registry = BackendsRegistry.new

    SimpleError = Struct.new(:msg_code)
    private_constant :SimpleError

    class << self
      attr_reader :registry

      def open(*args, **opts, &block)
        backend = opts.delete(:backend) || registry.get(*args, **opts)

        if backend.nil?
          return Utils::MonadicResult::Failure.new(SimpleError.new("no_applicable_backend"))
        end

        backend.open(*args, **opts, &block)
      end
    end
  end
end
