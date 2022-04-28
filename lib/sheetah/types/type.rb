# frozen_string_literal: true

require_relative "cast_chain"

module Sheetah
  module Types
    class Type
      class << self
        def all(&block)
          return enum_for(:all) unless block

          ObjectSpace.each_object(singleton_class, &block)
          nil
        end

        def cast_classes
          defined?(@cast_classes) ? @cast_classes : superclass.cast_classes
        end

        attr_writer :cast_classes

        def cast(cast_class = nil, &cast_block)
          if cast_class && cast_block
            raise ArgumentError, "Expected either a Class or a block, got both"
          elsif !(cast_class || cast_block)
            raise ArgumentError, "Expected either a Class or a block, got none"
          end

          type = Class.new(self)
          type.cast_classes += [cast_class || SimpleCast.new(cast_block)]
          type
        end

        def freeze
          @cast_classes = cast_classes.dup unless defined?(@cast_classes)
          @cast_classes.freeze
          super
        end

        def new!(...)
          new(...).freeze
        end
      end

      self.cast_classes = []

      def initialize(**opts)
        @cast_chain = CastChain.new

        self.class.cast_classes.each do |cast_class|
          @cast_chain.append(cast_class.new(**opts))
        end
      end

      # @private
      attr_reader :cast_chain

      def cast(...)
        @cast_chain.call(...)
      end

      def scalar?
        raise NoMethodError, "You must implement this method in a subclass"
      end

      def composite?
        raise NoMethodError, "You must implement this method in a subclass"
      end

      def scalar(_index, _value, _messenger)
        raise NoMethodError, "You must implement this method in a subclass"
      end

      def composite(_value, _messenger)
        raise NoMethodError, "You must implement this method in a subclass"
      end

      def freeze
        @cast_chain.freeze
        super
      end

      # @private
      class SimpleCast
        def initialize(cast)
          @cast = cast
        end

        def new(**)
          @cast
        end

        def ==(other)
          other.is_a?(self.class) && other.cast == cast
        end

        protected

        attr_reader :cast
      end
    end
  end
end
