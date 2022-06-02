# frozen_string_literal: true

require_relative "../cast"

module Sheetah
  module Types
    module Scalars
      class BoolsyCast
        include Cast

        TRUTHY = [true, 1].freeze
        FALSY  = [false, 0].freeze
        private_constant :TRUTHY, :FALSY

        def initialize(truthy: [], falsy: [], strict: false, **)
          @truthy = truthy
          @falsy  = falsy
          @strict = strict
        end

        def call(value, messenger)
          boolsy = strict_match(value)
          boolsy = loose_match(value) if boolsy.nil? && !@strict

          return boolsy unless boolsy.nil?

          messenger.error("must_be_boolsy", value: value.inspect)

          throw :failure
        end

        private

        def strict_match(value)
          if @truthy.include?(value)
            true
          elsif @falsy.include?(value)
            false
          end
        end

        def loose_match(value)
          if TRUTHY.include?(value)
            true
          elsif FALSY.include?(value)
            false
          end
        end
      end
    end
  end
end
