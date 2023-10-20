# frozen_string_literal: true

require_relative "composite"
require_relative "../../messaging/messages/must_be_array"

module Sheetah
  module Types
    module Composites
      Array = Composite.cast do |value, _messenger|
        throw :failure, Messaging::Messages::MustBeArray.new unless value.is_a?(::Array)

        value
      end
    end
  end
end
