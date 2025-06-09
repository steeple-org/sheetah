# frozen_string_literal: true

module Sheetah
  module Utils
    module MonadicResult
      # {Unit} is a singleton, and is used when there is no other meaningful
      # value that could be returned.
      #
      # It allows the {Result} implementation to distinguish between *a null
      # value* (i.e. `nil`) and *the lack of a value*, to provide adequate
      # behavior in each case.
      #
      # The {Result} API should not expose {Unit} directly to its consumers.
      #
      # @see https://en.wikipedia.org/wiki/Unit_type
      Unit = Object.new

      def Unit.to_s
        "Unit"
      end

      def Unit.inspect
        "Unit"
      end

      Unit.freeze

      DO_TOKEN = :MonadicResultDo
      private_constant :DO_TOKEN

      module Result
        UnwrapError  = Class.new(StandardError)
        VariantError = Class.new(UnwrapError)
        ValueError   = Class.new(UnwrapError)

        def initialize(value = Unit)
          @wrapped = value
        end

        def empty?
          wrapped == Unit
        end

        def ==(other)
          other.is_a?(self.class) && other.wrapped == wrapped
        end

        def inspect
          if empty?
            "#{variant}()"
          else
            "#{variant}(#{wrapped.inspect})"
          end
        end

        alias to_s inspect

        def discard
          empty? ? self : self.class.new
        end

        protected

        attr_reader :wrapped

        private

        def value
          raise ValueError, "There is no value within the result" if empty?

          wrapped
        end

        def value?
          wrapped unless empty?
        end

        def open
          if empty?
            yield
          else
            yield wrapped
          end
        end
      end

      class Success
        include Result

        def success?
          true
        end

        def failure?
          false
        end

        def success
          value
        end

        def failure
          raise VariantError, "Not a Failure"
        end

        def unwrap
          value?
        end

        alias bind open
        public :bind

        alias or itself

        private

        def variant
          "Success"
        end
      end

      class Failure
        include Result

        def success?
          false
        end

        def failure?
          true
        end

        def success
          raise VariantError, "Not a Success"
        end

        def failure
          value
        end

        def unwrap
          throw DO_TOKEN, self
        end

        alias bind itself

        alias or open
        public :or

        private

        def variant
          "Failure"
        end
      end

      # rubocop:disable Naming/MethodName

      def Success(...)
        Success.new(...)
      end

      def Failure(...)
        Failure.new(...)
      end

      def Do(&)
        catch(DO_TOKEN, &)
      end

      # rubocop:enable Naming/MethodName
    end
  end
end
