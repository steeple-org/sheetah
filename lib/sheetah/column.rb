# frozen_string_literal: true

module Sheetah
  class Column
    def initialize(key:, type:, index:, header:, header_pattern: nil, required: false)
      @key            = key
      @type           = type
      @index          = index
      @header         = header
      @header_pattern = (header_pattern || header.dup).freeze
      @required       = required

      freeze
    end

    attr_reader :key, :type, :index, :header, :header_pattern

    def required?
      @required
    end
  end
end
