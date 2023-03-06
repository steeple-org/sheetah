# frozen_string_literal: true

require_relative "../../utils/cell_string_cleaner"
require_relative "../../messaging/messages/must_exist"
require_relative "../../messaging/messages/cleaned_string"
require_relative "../cast"

module Sheetah
  module Types
    module Scalars
      class ScalarCast
        include Cast

        def initialize(nullable: true, clean_string: true, **)
          @nullable = nullable
          @clean_string = clean_string
        end

        def call(value, messenger)
          handle_nil(value)

          handle_garbage(value, messenger)
        end

        private

        def handle_nil(value)
          return unless value.nil?

          if @nullable
            throw :success, nil
          else
            throw :failure, Messaging::Messages::MustExist.new
          end
        end

        def handle_garbage(value, messenger)
          return value unless @clean_string && value.is_a?(::String)

          clean_string = Utils::CellStringCleaner.call(value)

          messenger.warn(Messaging::Messages::CleanedString.new) if clean_string != value

          clean_string
        end
      end
    end
  end
end
