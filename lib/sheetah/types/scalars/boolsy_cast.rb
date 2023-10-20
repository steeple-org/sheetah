# frozen_string_literal: true

require_relative "../../messaging/messages/must_be_boolsy"
require_relative "../cast"

module Sheetah
  module Types
    module Scalars
      class BoolsyCast
        include Cast

        TRUTHY = [].freeze
        FALSY  = [].freeze
        private_constant :TRUTHY, :FALSY

        def initialize(truthy: TRUTHY, falsy: FALSY, **)
          @truthy = truthy
          @falsy  = falsy
        end

        def call(value, _messenger)
          if @truthy.include?(value)
            true
          elsif @falsy.include?(value)
            false
          else
            throw :failure, Messaging::Messages::MustBeBoolsy.new(
              code_data: { value: value.inspect }
            )
          end
        end
      end
    end
  end
end
