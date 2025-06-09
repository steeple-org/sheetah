# frozen_string_literal: true

require_relative "errors/spec_error"

module Sheetah
  class Specification
    class InvalidPatternError < Errors::SpecError
    end

    class MutablePatternError < Errors::SpecError
    end

    class DuplicatedPatternError < Errors::SpecError
    end

    def initialize(ignore_unspecified_columns: false, report_ignored_columns: false)
      @column_by_pattern = {}
      @ignore_unspecified_columns = ignore_unspecified_columns
      @report_ignored_columns = report_ignored_columns
    end

    def set(pattern, column)
      if pattern.nil?
        raise InvalidPatternError, pattern.inspect
      end

      unless pattern.frozen?
        raise MutablePatternError, pattern.inspect
      end

      if @column_by_pattern.key?(pattern)
        raise DuplicatedPatternError, pattern.inspect
      end

      @column_by_pattern[pattern] = column
    end

    def get(header)
      return if header.nil?

      @column_by_pattern.each do |pattern, column|
        return column if pattern === header # rubocop:disable Style/CaseEquality
      end

      nil
    end

    def required_columns
      @column_by_pattern.each_value.select(&:required?)
    end

    def optional_columns
      @column_by_pattern.each_value.reject(&:required?)
    end

    def ignore_unspecified_columns?
      @ignore_unspecified_columns
    end

    def report_ignored_columns?
      @report_ignored_columns
    end

    def freeze
      @column_by_pattern.freeze
      super
    end
  end
end
