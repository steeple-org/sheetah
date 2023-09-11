# frozen_string_literal: true

require "set"
require_relative "messaging/messages/invalid_header"
require_relative "messaging/messages/duplicated_header"
require_relative "messaging/messages/missing_column"

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
          @messenger.error(
            Messaging::Messages::MissingColumn.new(code_data: { value: column.header })
          )
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
        @messenger.error(
          Messaging::Messages::InvalidHeader.new(code_data: { value: header.value })
        )
      end

      false
    end

    def add_ensure_column_is_unique(header, column)
      return true if @columns.add?(column)

      @failure = true
      @messenger.error(
        Messaging::Messages::DuplicatedHeader.new(code_data: { value: header.value })
      )

      false
    end
  end
end
