# frozen_string_literal: true

require_relative "../../errors/type_error"
require_relative "../type"

module Sheetah
  module Types
    module Composites
      class Composite < Type
        def initialize(types, **opts)
          super(**opts)

          @types = types
        end

        def composite?
          true
        end

        def scalar(index, value, messenger)
          if (type = @types[index])
            type.scalar(nil, value, messenger)
          else
            raise Errors::TypeError, "Invalid index: #{index.inspect}"
          end
        end

        alias composite cast
      end
    end
  end
end
