# frozen_string_literal: true

require_relative "types/container"

module Sheetah
  class TemplateConfig
    def initialize(types: Types::Container.new)
      @types = types
    end

    attr_reader :types

    def header(key, index)
      header = key.to_s.capitalize
      header = "#{header} #{index + 1}" if index

      pattern = /^#{header}$/i

      [header, pattern]
    end
  end
end
