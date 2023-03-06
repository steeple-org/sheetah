# frozen_string_literal: true

require_relative "backends_registry"
require_relative "messaging/messages/no_applicable_backend"
require_relative "utils/monadic_result"

module Sheetah
  module Backends
    @registry = BackendsRegistry.new

    class << self
      attr_reader :registry

      def open(*args, **opts, &block)
        backend = opts.delete(:backend) || registry.get(*args, **opts)

        if backend.nil?
          return Utils::MonadicResult::Failure.new(
            Messaging::Messages::NoApplicableBackend.new
          )
        end

        backend.open(*args, **opts, &block)
      end
    end
  end
end
