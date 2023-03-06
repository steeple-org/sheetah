# frozen_string_literal: true

require "date"
require_relative "../../messaging/messages/must_be_date"
require_relative "../cast"

module Sheetah
  module Types
    module Scalars
      class DateStringCast
        include Cast

        DATE_FMT = "%Y-%m-%d"
        private_constant :DATE_FMT

        def initialize(date_fmt: DATE_FMT, accept_date: true, **)
          @date_fmt = date_fmt
          @accept_date = accept_date
        end

        def call(value, _messenger)
          case value
          when ::Date
            return value if @accept_date
          when ::String
            date = parse_date_string(value)
            return date if date
          end

          throw :failure, Messaging::Messages::MustBeDate.new(code_data: { format: @date_fmt })
        end

        private

        def parse_date_string(value)
          ::Date.strptime(value, @date_fmt)
        rescue ::TypeError, ::Date::Error
          nil
        end
      end
    end
  end
end
