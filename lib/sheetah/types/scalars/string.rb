# frozen_string_literal: true

require_relative "scalar"
require_relative "../../messaging/messages/must_be_string"

module Sheetah
  module Types
    module Scalars
      String = Scalar.cast do |value, _messenger|
        # value.to_s, because we want the native, underlying string when value
        # is an instance of a String subclass
        next value.to_s if value.is_a?(::String)

        throw :failure, Messaging::Messages::MustBeString.new
      end
    end
  end
end
