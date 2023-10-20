# frozen_string_literal: true

require "uri"
require_relative "../../messaging/messages/must_be_email"
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

        def call(value, _messenger)
          return value if @email_matcher.match?(value)

          throw :failure, Messaging::Messages::MustBeEmail.new(code_data: { value: value.inspect })
        end
      end
    end
  end
end
