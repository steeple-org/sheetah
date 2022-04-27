# frozen_string_literal: true

require_relative "string"
require_relative "email_cast"

module Sheetah
  module Types
    module Scalars
      Email = String.cast(EmailCast)
    end
  end
end
