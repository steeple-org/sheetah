# frozen_string_literal: true

require_relative "../../errors/type_error"
require_relative "../type"
require_relative "scalar_cast"

module Sheetah
  module Types
    module Scalars
      class Scalar < Type
        self.cast_classes += [ScalarCast]

        def composite?
          false
        end

        def composite(_value, _messenger)
          raise Errors::TypeError, "A scalar type cannot act as a composite"
        end

        def scalar(index, value, messenger)
          raise Errors::TypeError, "A scalar type cannot be indexed" unless index.nil?

          cast_chain.call(value, messenger)
        end
      end
    end
  end
end
