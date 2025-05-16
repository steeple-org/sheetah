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

      def open(*, **opts, &)
        backend = opts.delete(:backend) || registry.get(*, **opts)

        if backend.nil?
          return Utils::MonadicResult::Failure.new(SimpleError.new("no_applicable_backend"))
        end

        backend.open(*, **opts, &)
      end
    end
  end
end
