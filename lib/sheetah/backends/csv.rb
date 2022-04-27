# frozen_string_literal: true

require "csv"
require_relative "../sheet"

module Sheetah
  module Backends
    # Expect:
    # - UTF-8 without BOM, or the correct encoding given explicitly
    # - line endings as \n or \r\n
    # - comma-separated
    # - quoted with "
    class Csv
      include Sheet

      class ArgumentError < Error
      end

      class EncodingError < Error
      end

      CSV_OPTS = {
        col_sep: ",",
        quote_char: '"',
      }.freeze

      private_constant :CSV_OPTS

      def initialize(io: nil, path: nil, encoding: nil)
        io = setup_io(io, path, encoding)

        @csv = CSV.new(io, **CSV_OPTS)
        @headers = detect_headers(@csv)
        @cols_count = @headers.size
      end

      def each_header
        return to_enum(:each_header) { @cols_count } unless block_given?

        @headers.each_with_index do |header, index|
          yield Header.new(col: index + 1, value: header)
        end

        self
      end

      def each_row
        return to_enum(:each_row) unless block_given?

        @csv.each.with_index(1) do |raw, row|
          value = Array.new(@cols_count) do |col_idx|
            Cell.new(row: row, col: col_idx + 1, value: raw[col_idx])
          end

          yield Row.new(row: row, value: value)
        end

        self
      end

      def close
        @csv.close

        nil
      end

      private

      def setup_io(io, path, encoding)
        if io.nil? && !path.nil?
          setup_io_from_path(path, encoding)
        elsif !io.nil? && path.nil?
          setup_io_from_io(io, encoding)
        else
          raise ArgumentError, "Expected either IO or path"
        end
      end

      def setup_io_from_io(io, encoding)
        io.set_encoding(encoding, Encoding::UTF_8) if encoding
        io
      end

      def setup_io_from_path(path, encoding)
        opts = { mode: "r" }

        if encoding
          opts[:external_encoding] = encoding
          opts[:internal_encoding] = Encoding::UTF_8
        end

        File.new(path, **opts)
      end

      def detect_headers(csv)
        headers =
          begin
            csv.shift
          rescue CSV::MalformedCSVError
            raise EncodingError
          end

        headers || []
      end
    end
  end
end
