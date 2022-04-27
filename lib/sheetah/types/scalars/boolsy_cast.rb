# frozen_string_literal: true

require_relative "../cast"

module Sheetah
  module Types
    module Scalars
      class BoolsyCast
        include Cast

        TRUTHY = [true].freeze
        FALSY  = [false].freeze
        private_constant :TRUTHY, :FALSY

        def initialize(truthy: TRUTHY, falsy: FALSY, **)
          @truthy = truthy
          @falsy = falsy
        end

        def call(value, messenger)
          if @truthy.include?(value)
            true
          elsif @falsy.include?(value)
            false
          else
            messenger.error("must_be_boolsy", value: value.inspect)

            throw :failure
          end
        end
      end
    end
  end
end
