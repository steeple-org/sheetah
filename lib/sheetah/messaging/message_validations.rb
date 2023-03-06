# frozen_string_literal: true

require_relative "../errors/error"
require_relative "constants"

module Sheetah
  module Messaging
    module MessageValidations
      class InvalidMessage < Errors::Error
      end

      class BaseValidator
        def self.cell
          include CellValidator
        end

        def self.col
          include ColValidator
        end

        def self.row
          include RowValidator
        end

        def self.sheet
          include SheetValidator
        end

        def validate(message)
          errors = []

          errors << "code"       unless validate_code(message)
          errors << "code_data"  unless validate_code_data(message)
          errors << "scope"      unless validate_scope(message)
          errors << "scope_data" unless validate_scope_data(message)

          return if errors.empty?

          raise InvalidMessage, "#{errors.join(", ")} <#{message.class}>#{message.to_h}"
        end

        def validate_code(message)
          message.code == message.class.code
        end
      end

      module CellValidator
        def validate_scope(message)
          message.scope == SCOPES::CELL
        end

        def validate_scope_data(message)
          case message.scope_data
          in { col: String, row: Integer }
            true
          else
            false
          end
        end
      end

      module ColValidator
        def validate_scope(message)
          message.scope == SCOPES::COL
        end

        def validate_scope_data(message)
          case message.scope_data
          in { col: String }
            true
          else
            false
          end
        end
      end

      module RowValidator
        def validate_scope(message)
          message.scope == SCOPES::ROW
        end

        def validate_scope_data(message)
          case message.scope_data
          in { row: Integer }
            true
          else
            false
          end
        end
      end

      module SheetValidator
        def validate_scope(message)
          message.scope == SCOPES::SHEET
        end

        def validate_scope_data(message)
          message.scope_data.nil?
        end
      end

      module ClassMethods
        def validate_with(&block)
          @validator = Class.new(BaseValidator, &block).new.freeze
        end

        def validator
          if defined?(@validator)
            @validator
          elsif superclass.respond_to?(:validator)
            superclass.validator
          end
        end

        def validate(message)
          validator&.validate(message)
        end
      end

      def self.included(message_class)
        message_class.extend(ClassMethods)
      end

      def validate
        self.class.validate(self) if @validatable
      end
    end
  end
end
