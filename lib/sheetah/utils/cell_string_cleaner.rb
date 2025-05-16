# frozen_string_literal: true

module Sheetah
  module Utils
    class CellStringCleaner
      garbage = "(?:[^[:print:]]|[[:space:]])+"
      GARBAGE_PREFIX = /\A#{garbage}/
      GARBAGE_SUFFIX = /#{garbage}\Z/
      private_constant :GARBAGE_PREFIX, :GARBAGE_SUFFIX

      def self.call(...)
        DEFAULT.call(...)
      end

      def call(value)
        value = value.dup

        # TODO: benchmarks
        value.sub!(GARBAGE_PREFIX, "")
        value.sub!(GARBAGE_SUFFIX, "")

        value
      end

      DEFAULT = new.freeze
      private_constant :DEFAULT
    end
  end
end
