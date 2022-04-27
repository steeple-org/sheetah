# frozen_string_literal: true

require_relative "scalar"
require_relative "boolsy_cast"

module Sheetah
  module Types
    module Scalars
      Boolsy = Scalar.cast(BoolsyCast)
    end
  end
end
