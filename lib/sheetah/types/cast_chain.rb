# frozen_string_literal: true

require_relative "../utils/monadic_result"

module Sheetah
  module Types
    class CastChain
      include Utils::MonadicResult

      def initialize(casts = [])
        @casts = casts
      end

      attr_reader :casts

      def prepend(cast)
        @casts.unshift(cast)
        self
      end

      def append(cast)
        @casts.push(cast)
        self
      end

      def freeze
        @casts.each(&:freeze)
        @casts.freeze
        super
      end

      def call(value, messenger)
        failure = catch(:failure) do
          success = catch(:success) do
            @casts.reduce(value) do |prev_value, cast|
              cast.call(prev_value, messenger)
            end
          end

          return Success(success)
        end

        messenger.error(failure) if failure

        Failure()
      end
    end
  end
end
