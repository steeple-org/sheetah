# frozen_string_literal: true

require_relative "array"

module Sheetah
  module Types
    module Composites
      ArrayCompact = Array.cast do |value, _messenger|
        value.compact
      end
    end
  end
end
