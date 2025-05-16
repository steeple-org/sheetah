# frozen_string_literal: true

require_relative "../sheet"

module Sheetah
  module Backends
    class Wrapper
      include Sheet

      def initialize(table)
        raise Error if table.nil?

        @table = table

        if (table_size = @table.size).positive?
          @headers    = @table[0]
          @rows_count = table_size - 1
          @cols_count = @headers.size
        else
          @headers    = []
          @rows_count = 0
          @cols_count = 0
        end
      end

      def each_header
        return to_enum(:each_header) { @cols_count } unless block_given?

        1.upto(@cols_count) do |col|
          yield Header.new(col: Sheet.int2col(col), value: @headers[col - 1])
        end

        self
      end

      def each_row
        return to_enum(:each_row) unless block_given?

        1.upto(@rows_count) do |row|
          raw = @table[row]

          value = Array.new(@cols_count) do |col_idx|
            Cell.new(row:, col: Sheet.int2col(col_idx + 1), value: raw[col_idx])
          end

          yield Row.new(row:, value:)
        end

        self
      end

      def close
        # nothing to do here
      end
    end
  end
end
