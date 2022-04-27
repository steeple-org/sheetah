# frozen_string_literal: true

require_relative "column"

module Sheetah
  class Attribute
    def initialize(key:, type:)
      @key = key

      @type =
        case type
        when Hash
          CompositeType.new(**type)
        when Array
          CompositeType.new(composite: :array, scalars: type)
        else
          ScalarType.new(type)
        end

      freeze
    end

    attr_reader :key, :type

    def each_column(config)
      return enum_for(:each_column, config) unless block_given?

      compiled_type = type.compile(config.types)

      type.each_column do |index|
        header, header_pattern = config.header(key, index)

        yield Column.new(
          key: key,
          type: compiled_type,
          index: index,
          header: header,
          header_pattern: header_pattern
        )
      end
    end

    class ScalarType
      def initialize(scalar)
        @scalar = scalar
        freeze
      end

      def compile(container)
        container.scalar(@scalar)
      end

      def each_column
        return enum_for(:each_column) { 1 } unless block_given?

        yield nil

        self
      end
    end

    class CompositeType
      def initialize(composite:, scalars:)
        @composite = composite
        @scalars = scalars.freeze
        freeze
      end

      def compile(container)
        container.composite(@composite, @scalars)
      end

      def each_column(&block)
        @scalars.each_index(&block)

        self
      end
    end

    private_constant :ScalarType, :CompositeType
  end
end
