# frozen_string_literal: true

require_relative "sheet/col_converter"
require_relative "errors/error"
require_relative "utils/monadic_result"

module Sheetah
  module Sheet
    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def self.col2int(...)
      COL_CONVERTER.col2int(...)
    end

    def self.int2col(...)
      COL_CONVERTER.int2col(...)
    end

    module ClassMethods
      def open(*args, **opts)
        handle_sheet_error do
          sheet = new(*args, **opts)
          next sheet unless block_given?

          begin
            yield sheet
          ensure
            sheet.close
          end
        end
      end

      private

      def handle_sheet_error
        Utils::MonadicResult::Success.new(yield)
      rescue Error => e
        Utils::MonadicResult::Failure.new(e)
      end
    end

    class Error < Errors::Error
      def msg_code
        "sheet_error"
      end
    end

    class Header
      def initialize(col:, value:)
        @col = col
        @value = value
      end

      attr_reader :col, :value

      def ==(other)
        other.is_a?(self.class) && col == other.col && value == other.value
      end

      def row_value_index
        Sheet.col2int(col) - 1
      end
    end

    class Row
      def initialize(row:, value:)
        @row = row
        @value = value
      end

      attr_reader :row, :value

      def ==(other)
        other.is_a?(self.class) && row == other.row && value == other.value
      end
    end

    class Cell
      def initialize(row:, col:, value:)
        @row = row
        @col = col
        @value = value
      end

      attr_reader :row, :col, :value

      def ==(other)
        other.is_a?(self.class) && row == other.row && col == other.col && value == other.value
      end
    end

    def each_header
      raise NoMethodError, "You must implement #{self.class}#each_header => self"
    end

    def each_row
      raise NoMethodError, "You must implement #{self.class}#each_row => self"
    end

    def close
      raise NoMethodError, "You must implement #{self.class}#close => nil"
    end
  end
end
