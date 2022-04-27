# frozen_string_literal: true

require "uri"
require_relative "../cast"

module Sheetah
  module Types
    module Scalars
      class EmailCast
        include Cast

        EMAIL_REGEXP = ::URI::MailTo::EMAIL_REGEXP
        private_constant :EMAIL_REGEXP

        def initialize(email_matcher: EMAIL_REGEXP, **)
          @email_matcher = email_matcher
        end

        def call(value, messenger)
          return value if @email_matcher.match?(value)

          messenger.error("must_be_email", value: value.inspect)

          throw :failure
        end
      end
    end
  end
end
