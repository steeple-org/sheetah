# frozen_string_literal: true

require "set"

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

        if column.nil?
          @failure = true
          @messenger.error("invalid_header", header.value)
          return
        end

        unless @columns.add?(column)
          @failure = true
          @messenger.error("duplicated_header", header.value)
          return
        end

        @headers << Header.new(header, column)
      end
    end

    def result
      if @failure
        Failure()
      else
        Success(@headers)
      end
    end
  end
end