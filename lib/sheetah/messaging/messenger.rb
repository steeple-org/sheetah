# frozen_string_literal: true

require_relative "constants"
require_relative "message"

module Sheetah
  module Messaging
    class Messenger
      def initialize(
        scope: SCOPES::SHEET,
        scope_data: nil
      )
        @scope = scope.freeze
        @scope_data = scope_data.freeze
        @messages = []
      end

      attr_reader :scope, :scope_data, :messages

      def ==(other)
        other.is_a?(self.class) &&
          scope      == other.scope &&
          scope_data == other.scope_data &&
          messages   == other.messages
      end

      def dup
        self.class.new(
          scope: @scope,
          scope_data: @scope_data
        )
      end

      def scoping!(scope, scope_data, &block)
        scope      = scope.freeze
        scope_data = scope_data.freeze

        if block
          replace_scoping_block(scope, scope_data, &block)
        else
          replace_scoping_noblock(scope, scope_data)
        end
      end

      def scoping(...)
        dup.scoping!(...)
      end

      def scope_row!(row, &block)
        scope = case @scope
                when SCOPES::COL, SCOPES::CELL
                  SCOPES::CELL
                else
                  SCOPES::ROW
                end

        scope_data = @scope_data.dup || {}
        scope_data[:row] = row

        scoping!(scope, scope_data, &block)
      end

      def scope_col!(col, &block)
        scope = case @scope
                when SCOPES::ROW, SCOPES::CELL
                  SCOPES::CELL
                else
                  SCOPES::COL
                end

        scope_data = @scope_data.dup || {}
        scope_data[:col] = col

        scoping!(scope, scope_data, &block)
      end

      def scope_row(...)
        dup.scope_row!(...)
      end

      def scope_col(...)
        dup.scope_col!(...)
      end

      def warn(code, data = nil)
        add(SEVERITIES::WARN, code, data)
      end

      def error(code, data = nil)
        add(SEVERITIES::ERROR, code, data)
      end

      private

      def add(severity, code, data)
        messages << Message.new(
          code: code,
          code_data: data,
          scope: @scope,
          scope_data: @scope_data,
          severity: severity
        )

        self
      end

      def replace_scoping_noblock(new_scope, new_scope_data)
        @scope      = new_scope
        @scope_data = new_scope_data

        self
      end

      def replace_scoping_block(new_scope, new_scope_data)
        prev_scope      = @scope
        prev_scope_data = @scope_data

        @scope      = new_scope
        @scope_data = new_scope_data

        begin
          yield self
        ensure
          @scope = prev_scope
          @scope_data = prev_scope_data
        end
      end
    end
  end
end
