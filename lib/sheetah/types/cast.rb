# frozen_string_literal: true

module Sheetah
  module Types
    # @private
    module Cast
      def ==(other)
        other.is_a?(self.class) && other.config == config
      end

      protected

      def config
        instance_variables.each_with_object({}) do |ivar, acc|
          acc[ivar] = instance_variable_get(ivar)
        end
      end
    end
  end
end
