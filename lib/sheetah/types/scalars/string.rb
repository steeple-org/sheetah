# frozen_string_literal: true

require_relative "scalar"

module Sheetah
  module Types
    module Scalars
      String = Scalar.cast do |value, _messenger|
        next value if value.is_a?(::String)

        throw :failure, "must_be_string"
      end
    end
  end
end
