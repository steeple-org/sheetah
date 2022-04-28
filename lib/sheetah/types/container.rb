# frozen_string_literal: true

require_relative "../errors/type_error"

require_relative "scalars/scalar"
require_relative "scalars/string"
require_relative "scalars/email"
require_relative "scalars/boolsy"
require_relative "scalars/date_string"
require_relative "composites/array"
require_relative "composites/array_compact"

module Sheetah
  module Types
    class Container
      scalar      = Scalars::Scalar.new!
      string      = Scalars::String.new!
      email       = Scalars::Email.new!
      boolsy      = Scalars::Boolsy.new!
      date_string = Scalars::DateString.new!

      DEFAULTS = {
        scalars: {
          scalar:      -> { scalar },
          string:      -> { string },
          email:       -> { email  },
          boolsy:      -> { boolsy },
          date_string: -> { date_string },
        }.freeze,
        composites: {
          array:         ->(types) { Composites::Array.new!(types) },
          array_compact: ->(types) { Composites::ArrayCompact.new!(types) },
        }.freeze,
      }.freeze

      def initialize(scalars: nil, composites: nil, defaults: DEFAULTS)
        @scalars =
          (scalars ? defaults[:scalars].merge(scalars) : defaults[:scalars]).freeze

        @composites =
          (composites ? defaults[:composites].merge(composites) : defaults[:composites]).freeze
      end

      def scalars
        @scalars.keys
      end

      def composites
        @composites.keys
      end

      def scalar(scalar_name)
        builder = fetch_scalar_builder(scalar_name)

        builder.call
      end

      def composite(composite_name, scalar_names)
        builder = fetch_composite_builder(composite_name)

        scalars = scalar_names.map { |scalar_name| scalar(scalar_name) }

        builder.call(scalars)
      end

      private

      def fetch_scalar_builder(type)
        @scalars.fetch(type) do
          raise Errors::TypeError, "Invalid scalar type: #{type.inspect}"
        end
      end

      def fetch_composite_builder(type)
        @composites.fetch(type) do
          raise Errors::TypeError, "Invalid composite type: #{type.inspect}"
        end
      end
    end
  end
end
