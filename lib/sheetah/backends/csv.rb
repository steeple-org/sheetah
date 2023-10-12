# frozen_string_literal: true

require "csv"

require_relative "../sheet"

module Sheetah
  module Backends
    class Csv
      include Sheet

      class InvalidCSVError < Error
      end

      DEFAULTS = {
        row_sep: :auto,
        col_sep: ",",
        quote_char: '"',
      }.freeze

      private_constant :DEFAULTS

      def self.defaults
        DEFAULTS
      end

      def initialize(
        io,
        row_sep: self.class.defaults[:row_sep],
        col_sep: self.class.defaults[:col_sep],
        quote_char: self.class.defaults[:quote_char]
      )
        @csv = CSV.new(
          io,
          row_sep: row_sep,
          col_sep: col_sep,
          quote_char: quote_char
        )

        @headers = detect_headers(@csv)
        @cols_count = @headers.size
      end

      def each_header
        return to_enum(:each_header) { @cols_count } unless block_given?

        @headers.each_with_index do |header, col_idx|
          col = Sheet.int2col(col_idx + 1)

          yield Header.new(col: col, value: header)
        end

        self
      end

      def each_row
        return to_enum(:each_row) unless block_given?

        handle_malformed_csv do
          @csv.each.with_index(1) do |raw, row|
            value = Array.new(@cols_count) do |col_idx|
              col = Sheet.int2col(col_idx + 1)

              Cell.new(row: row, col: col, value: raw[col_idx])
            end

            yield Row.new(row: row, value: value)
          end
        end

        self
      end

      def close
        # Do nothing: this backend isn't responsible for opening the IO, and therefore it is not
        # responsible for closing it either.
      end

      private

      def handle_malformed_csv
        yield
      rescue CSV::MalformedCSVError
        raise InvalidCSVError
      end

      def detect_headers(csv)
        handle_malformed_csv { csv.shift } || []
      end
    end
  end
end
