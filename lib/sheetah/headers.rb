# frozen_string_literal: true

module Sheetah
  class Headers
    include Utils::MonadicResult

    class Header
      def initialize(sheet_header, spec_column)
        @header = sheet_header
        @column = spec_column
      end

      attr_reader :header, :column

      def ==(other)
        other.is_a?(self.class) &&
          header == other.header &&
          column == other.column
      end

      def row_value_index
        header.row_value_index
      end
    end

    def initialize(specification:, messenger:)
      @specification = specification
      @messenger = messenger
      @headers = []
      @columns = Set.new
      @failure = false
    end

    def add(header)
      @messenger.scope_col!(header.col) do
        column = @specification.get(header.value)

        return unless add_ensure_column_is_specified(header, column)
        return unless add_ensure_column_is_unique(header, column)

        @headers << Header.new(header, column)
      end
    end

    def result
      missing_columns = @specification.required_columns - @columns.to_a

      unless missing_columns.empty?
        @failure = true

        missing_columns.each do |column|
          @messenger.error("missing_column", column.header)
        end
      end

      if @failure
        Failure()
      else
        Success(@headers)
      end
    end

    private

    def add_ensure_column_is_specified(header, column)
      return true unless column.nil?

      unless @specification.ignore_unspecified_columns?
        @failure = true
        @messenger.error("invalid_header", header.value)
      end

      @messenger.warn("ignored_column", header.value) if @specification.report_ignored_columns?

      false
    end

    def add_ensure_column_is_unique(header, column)
      return true if @columns.add?(column)

      @failure = true
      @messenger.error("duplicated_header", header.value)

      false
    end
  end
end
