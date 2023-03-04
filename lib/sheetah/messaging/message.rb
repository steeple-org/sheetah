# frozen_string_literal: true

require_relative "constants"

module Sheetah
  module Messaging
    class Message
      def initialize(
        code:,
        code_data: nil,
        scope: nil,
        scope_data: nil,
        severity: nil
      )
        @code        = code
        @code_data   = code_data   || nil
        @scope       = scope       || SCOPES::SHEET
        @scope_data  = scope_data  || nil
        @severity    = severity    || SEVERITIES::WARN
      end

      attr_reader(
        :code,
        :code_data,
        :scope,
        :scope_data,
        :severity
      )

      def ==(other)
        other.is_a?(self.class) &&
          code       == other.code &&
          code_data  == other.code_data &&
          scope      == other.scope &&
          scope_data == other.scope_data &&
          severity   == other.severity
      end

      def to_s
        parts = [scoping_to_s, "#{severity}: #{code}", code_data]
        parts.compact!
        parts.join(" ")
      end

      private

      def scoping_to_s
        case scope
        when SCOPES::SHEET then "[#{scope}]"
        when SCOPES::ROW   then "[#{scope}: #{scope_data[:row]}]"
        when SCOPES::COL   then "[#{scope}: #{scope_data[:col]}]"
        when SCOPES::CELL  then "[#{scope}: #{scope_data[:col]}#{scope_data[:row]}]"
        end
      end
    end
  end
end
