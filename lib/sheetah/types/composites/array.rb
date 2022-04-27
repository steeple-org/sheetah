# frozen_string_literal: true

require_relative "composite"

module Sheetah
  module Types
    module Composites
      Array = Composite.cast do |value, _messenger|
        throw :failure, "must_be_array" unless value.is_a?(::Array)

        value
      end
    end
  end
end
