# frozen_string_literal: true

require "set"
require_relative "utils/monadic_result"

module Sheetah
  class RowValueBuilder
    include Utils::MonadicResult

    def initialize(messenger)
      @messenger  = messenger
      @data       = {}
      @composites = Set.new
      @failure    = false
    end

    def add(column, value)
      key = column.key
      type = column.type
      index = column.index

      result = type.scalar(index, value, @messenger)

      result.bind do |scalar|
        if type.composite?
          @composites << [key, type]
          @data[key] ||= []
          @data[key][index] = scalar
        else
          @data[key] = scalar
        end
      end

      result.or { @failure = true }

      result
    end

    def result
      return Failure() if @failure

      Do() do
        @composites.each do |key, type|
          value = type.composite(@data[key], @messenger).unwrap

          @data[key] = value
        end

        Success(@data)
      end
    end
  end
end
