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

      type.each_column do |index, required|
        header, header_pattern = config.header(key, index)

        yield Column.new(
          key:,
          type: compiled_type,
          index:,
          header:,
          header_pattern:,
          required:
        )
      end
    end

    class Scalar
      def initialize(name)
        @required = name.end_with?("!")
        @name = (@required ? name.slice(0..-2) : name).to_sym
      end

      attr_reader :name, :required
    end

    class ScalarType
      def initialize(scalar)
        @scalar = Scalar.new(scalar)
        freeze
      end

      def compile(container)
        container.scalar(@scalar.name)
      end

      def each_column
        return enum_for(:each_column) { 1 } unless block_given?

        yield nil, @scalar.required

        self
      end
    end

    class CompositeType
      def initialize(composite:, scalars:)
        @composite = composite
        @scalars = scalars.map { |scalar| Scalar.new(scalar) }.freeze
        freeze
      end

      def compile(container)
        container.composite(@composite, @scalars.map(&:name))
      end

      def each_column
        return enum_for(:each_column) { @scalars.size } unless block_given?

        @scalars.each_with_index do |scalar, index|
          yield index, scalar.required
        end

        self
      end
    end

    private_constant :Scalar, :ScalarType, :CompositeType
  end
end
